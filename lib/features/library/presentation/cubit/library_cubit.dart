import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/domain/usecases/watch_auth_state.dart';
import '../../../games/domain/usecases/get_games_by_ids.dart';
import '../../../prices/domain/usecases/save_price_alert.dart';
import '../../domain/models/library_entry.dart';
import '../../domain/models/library_game.dart';
import '../../domain/models/library_status.dart';
import '../../domain/usecases/set_game_status.dart';
import '../../domain/usecases/watch_library.dart';
import 'library_state.dart';

class LibraryCubit extends Cubit<LibraryState> {
  LibraryCubit({
    required WatchAuthState watchAuthState,
    required WatchLibrary watchLibrary,
    required SetGameStatus setGameStatus,
    required GetGamesByIds getGamesByIds,
    required SavePriceAlert savePriceAlert,
  }) : _watchAuthState = watchAuthState,
       _watchLibrary = watchLibrary,
       _setGameStatus = setGameStatus,
       _getGamesByIds = getGamesByIds,
       _savePriceAlert = savePriceAlert,
       super(const LibraryInitial());

  final WatchAuthState _watchAuthState;
  final WatchLibrary _watchLibrary;
  final SetGameStatus _setGameStatus;
  final GetGamesByIds _getGamesByIds;
  final SavePriceAlert _savePriceAlert;

  StreamSubscription<AppUser?>? _authSub;
  StreamSubscription<List<LibraryEntry>>? _librarySub;
  LibraryFilter _filter = LibraryFilter.all;
  List<LibraryEntry> _entries = const [];

  void start() {
    _authSub ??= _watchAuthState().listen((user) {
      if (user == null) {
        unawaited(_librarySub?.cancel());
        _librarySub = null;
        _entries = const [];
        emit(const LibraryLoaded(
          entries: [],
          games: [],
          filter: LibraryFilter.all,
        ));
        return;
      }
      _listenLibrary();
    });
  }

  void _listenLibrary() {
    unawaited(_librarySub?.cancel());
    emit(LibraryLoading(filter: _filter));
    _librarySub = _watchLibrary().listen(
      (entries) {
        _entries = entries;
        unawaited(_hydrate(entries));
      },
      onError: (Object error) {
        emit(LibraryError(_messageFrom(error), filter: _filter));
      },
    );
  }

  Future<void> _hydrate(List<LibraryEntry> entries) async {
    try {
      final games = await _getGamesByIds(
        entries.map((entry) => entry.gameId).toList(),
      );
      final byId = {for (final game in games) game.id: game};
      final hydrated = [
        for (final entry in entries)
          if (byId[entry.gameId] != null)
            LibraryGame(game: byId[entry.gameId]!, entry: entry),
      ];
      if (isClosed) {
        return;
      }
      emit(
        LibraryLoaded(
          entries: entries,
          games: hydrated,
          filter: _filter,
        ),
      );
    } catch (error) {
      if (isClosed) {
        return;
      }
      emit(LibraryError(_messageFrom(error), filter: _filter));
    }
  }

  void setFilter(LibraryFilter filter) {
    _filter = filter;
    final current = state;
    if (current is LibraryLoaded) {
      emit(
        LibraryLoaded(
          entries: current.entries,
          games: current.games,
          filter: filter,
        ),
      );
      return;
    }
    emit(LibraryLoading(filter: filter));
  }

  Future<void> setStatus({
    required String gameId,
    required LibraryStatus status,
  }) async {
    try {
      await _setGameStatus(gameId: gameId, status: status);
    } catch (error) {
      emit(LibraryError(_messageFrom(error), filter: _filter));
      emit(
        LibraryLoaded(
          entries: _entries,
          games: state is LibraryLoaded
              ? (state as LibraryLoaded).games
              : const [],
          filter: _filter,
        ),
      );
    }
  }

  Future<void> savePriceAlert({
    required String gameId,
    required bool enabled,
    required List<String> stores,
  }) {
    return _savePriceAlert(
      gameId: gameId,
      enabled: enabled,
      stores: stores,
    );
  }

  Future<void> retry() async {
    _listenLibrary();
  }

  String _messageFrom(Object error) {
    if (error is Failure) {
      return error.message;
    }
    return 'No se pudo cargar la biblioteca.';
  }

  @override
  Future<void> close() async {
    await _authSub?.cancel();
    await _librarySub?.cancel();
    return super.close();
  }
}
