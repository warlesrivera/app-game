import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/models/game.dart';
import '../../domain/usecases/get_game_details.dart';
import '../../domain/usecases/get_game_guide.dart';
import '../../domain/usecases/get_game_videos.dart';
import '../../domain/usecases/translate_game_description.dart';
import 'game_details_state.dart';

class GameDetailsCubit extends Cubit<GameDetailsState> {
  GameDetailsCubit({
    required Game preview,
    required GetGameDetails getGameDetails,
    required GetGameVideos getGameVideos,
    TranslateGameDescription? translateDescription,
    GetGameGuide? getGameGuide,
  }) : _getGameDetails = getGameDetails,
       _getGameVideos = getGameVideos,
       _translateDescription = translateDescription,
       _getGameGuide = getGameGuide,
       super(
         GameDetailsState(
           game: preview,
           loadingDescription: !_hasText(preview.description) &&
               !_hasText(preview.descriptionEs),
           loadingVideos: true,
         ),
       );

  final GetGameDetails _getGameDetails;
  final GetGameVideos _getGameVideos;
  final TranslateGameDescription? _translateDescription;
  final GetGameGuide? _getGameGuide;

  Future<void> load() async {
    final id = int.tryParse(state.game.id);
    if (id == null) {
      if (!isClosed) {
        emit(
          state.copyWith(
            loadingDescription: false,
            loadingVideos: false,
          ),
        );
      }
      return;
    }

    if (!isClosed) {
      emit(
        state.copyWith(
          loadingDescription:
              !_hasText(state.game.description) &&
              !_hasText(state.game.descriptionEs),
          loadingVideos: true,
          clearError: true,
        ),
      );
    }

    await Future.wait([
      _loadDetails(id),
      _loadVideos(id),
    ]);
  }

  Future<void> _loadDetails(int id) async {
    try {
      final game = await _getGameDetails(id);
      if (isClosed) {
        return;
      }
      emit(state.copyWith(game: game, loadingDescription: false));
      await _translateIfNeeded(game);
    } catch (error) {
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          loadingDescription: false,
          error: _messageFrom(error),
        ),
      );
    }
  }

  Future<void> _loadVideos(int id) async {
    try {
      final videos = await _getGameVideos(id);
      if (isClosed) {
        return;
      }
      emit(state.copyWith(videos: videos, loadingVideos: false));
    } catch (_) {
      if (isClosed) {
        return;
      }
      emit(state.copyWith(loadingVideos: false));
    }
  }

  Future<void> loadGuide() async {
    final getGuide = _getGameGuide;
    if (getGuide == null || state.guide != null || state.loadingGuide) {
      return;
    }

    emit(state.copyWith(loadingGuide: true));
    try {
      final guide = await getGuide(state.game);
      if (isClosed) {
        return;
      }
      emit(state.copyWith(guide: guide, loadingGuide: false));
    } catch (_) {
      if (isClosed) {
        return;
      }
      emit(state.copyWith(loadingGuide: false));
    }
  }

  Future<void> _translateIfNeeded(Game game) async {
    final translate = _translateDescription;
    if (translate == null) {
      return;
    }
    final existing = game.descriptionEs?.trim();
    if (existing != null && existing.isNotEmpty) {
      return;
    }
    if (game.description == null || game.description!.trim().isEmpty) {
      return;
    }

    emit(state.copyWith(translating: true));
    try {
      final updated = await translate(game);
      if (isClosed) {
        return;
      }
      emit(state.copyWith(game: updated, translating: false));
    } catch (_) {
      if (isClosed) {
        return;
      }
      emit(state.copyWith(translating: false));
    }
  }

  String _messageFrom(Object error) {
    if (error is Failure) {
      return error.message;
    }
    return 'No se pudieron cargar más detalles.';
  }
}

bool _hasText(String? value) {
  return value != null && value.trim().isNotEmpty;
}
