import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../library/domain/models/game_taste.dart';
import '../../../library/domain/models/library_game.dart';
import '../../../library/domain/models/library_status.dart';
import '../../../library/presentation/cubit/library_state.dart';
import '../../data/datasources/player_analysis_remote_datasource.dart';
import '../../domain/models/genre_radar.dart';
import '../../domain/models/player_analysis.dart';
import '../../domain/usecases/generate_player_profile.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileInsightState> {
  ProfileCubit({
    required GeneratePlayerProfile generatePlayerProfile,
    required PlayerAnalysisRemoteDataSource analysisRemote,
  }) : _generatePlayerProfile = generatePlayerProfile,
       _analysisRemote = analysisRemote,
       super(const ProfileInsightState());

  final GeneratePlayerProfile _generatePlayerProfile;
  final PlayerAnalysisRemoteDataSource _analysisRemote;

  LibraryState _library = const LibraryInitial();
  var _loadedRemote = false;

  Future<void> sync(LibraryState library) async {
    _library = library;
    final games = library is LibraryLoaded
        ? library.games
        : const <LibraryGame>[];
    final radar = GenreRadar.fromLibrary(games);
    final fingerprint = PlayerAnalysis.fingerprintFor(games);

    if (!_loadedRemote) {
      emit(
        state.copyWith(
          radar: radar,
          fingerprint: fingerprint,
          loadingLore: true,
          clearError: true,
        ),
      );
      try {
        final saved = await _analysisRemote.get();
        if (isClosed) {
          return;
        }
        _loadedRemote = true;
        final needsSync =
            radar.hasData &&
            (saved == null || saved.fingerprint != fingerprint);
        emit(
          state.copyWith(
            radar: radar,
            fingerprint: fingerprint,
            analysis: saved,
            clearAnalysis: saved == null,
            loadingLore: false,
            needsSync: needsSync,
            clearError: true,
          ),
        );
        final outdated =
            saved != null && !saved.fingerprint.startsWith('v:psych');
        if ((saved == null || outdated) && radar.hasData) {
          await refreshAnalysis();
        }
        return;
      } catch (_) {
        if (isClosed) {
          return;
        }
        _loadedRemote = true;
        emit(
          state.copyWith(
            radar: radar,
            fingerprint: fingerprint,
            loadingLore: false,
            needsSync: radar.hasData,
          ),
        );
        return;
      }
    }

    final saved = state.analysis;
    emit(
      state.copyWith(
        radar: radar,
        fingerprint: fingerprint,
        needsSync:
            radar.hasData &&
            (saved == null || saved.fingerprint != fingerprint),
        clearError: true,
      ),
    );
  }

  Future<void> refreshAnalysis() async {
    final library = _library;
    final games = library is LibraryLoaded
        ? library.games
        : const <LibraryGame>[];
    final radar = GenreRadar.fromLibrary(games);
    if (!radar.hasData) {
      emit(state.copyWith(loadingLore: false, needsSync: false));
      return;
    }

    final fingerprint = PlayerAnalysis.fingerprintFor(games);
    emit(
      state.copyWith(
        radar: radar,
        fingerprint: fingerprint,
        loadingLore: true,
        clearError: true,
      ),
    );

    try {
      final favorites = library.favoriteGames;
      final liked = [
        for (final item in games)
          if (item.entry.taste == GameTaste.liked) item.game.name,
      ];
      final disliked = [
        for (final item in games)
          if (item.entry.taste == GameTaste.disliked) item.game.name,
      ];
      List<String> namesFor(LibraryStatus status) {
        return [
          for (final item in games)
            if (item.entry.status == status) item.game.name,
        ].take(8).toList();
      }

      final analysis = await _generatePlayerProfile(
        completed: library.stats.completed,
        abandoned: library.stats.abandoned,
        playing: library.stats.playing,
        favoriteGenre: radar.favoriteGenre,
        topFavorites: [for (final item in favorites.take(5)) item.game.name],
        genreCounts: {for (final axis in radar.axes) axis.label: axis.count},
        fingerprint: fingerprint,
        liked: liked,
        disliked: disliked,
        playingNames: namesFor(LibraryStatus.playing),
        completedNames: namesFor(LibraryStatus.completed),
        abandonedNames: namesFor(LibraryStatus.abandoned),
      );
      if (isClosed) {
        return;
      }
      if (analysis == null) {
        emit(
          state.copyWith(
            loadingLore: false,
            needsSync: true,
            error: 'No se pudo generar el análisis ahora.',
          ),
        );
        return;
      }
      await _analysisRemote.save(analysis);
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          analysis: analysis,
          loadingLore: false,
          needsSync: false,
          clearError: true,
        ),
      );
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            loadingLore: false,
            needsSync: true,
            error: 'No se pudo guardar el análisis.',
          ),
        );
      }
    }
  }
}
