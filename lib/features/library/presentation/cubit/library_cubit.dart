import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/domain/usecases/watch_auth_state.dart';
import '../../../games/domain/usecases/get_games_by_ids.dart';
import '../../../prices/domain/usecases/save_price_alert.dart';
import '../../domain/models/library_entry.dart';
import '../../domain/models/library_game.dart';
import '../../domain/models/library_status.dart';
import '../../domain/usecases/remove_game_from_library.dart';
import '../../domain/usecases/set_game_status.dart';
import '../../domain/usecases/watch_library.dart';
import 'library_state.dart';

class LibraryCubit extends Cubit<LibraryState> {
  LibraryCubit({
    required WatchAuthState watchAuthState,
    required WatchLibrary watchLibrary,
    required SetGameStatus setGameStatus,
    required RemoveGameFromLibrary removeGameFromLibrary,
    required GetGamesByIds getGamesByIds,
    required SavePriceAlert savePriceAlert,
  }) : _watchAuthState = watchAuthState,
       _watchLibrary = watchLibrary,
       _setGameStatus = setGameStatus,
       _removeGameFromLibrary = removeGameFromLibrary,
       _getGamesByIds = getGamesByIds,
       _savePriceAlert = savePriceAlert,
       super(const LibraryInitial());

  final WatchAuthState _watchAuthState;
  final WatchLibrary _watchLibrary;
  final SetGameStatus _setGameStatus;
  final RemoveGameFromLibrary _removeGameFromLibrary;
  final GetGamesByIds _getGamesByIds;
  final SavePriceAlert _savePriceAlert;

  StreamSubscription<AppUser?>? _authSub;
  StreamSubscription<List<LibraryEntry>>? _librarySub;
  LibraryFilter _filter = LibraryFilter.all;
  LibraryLayout _layout = LibraryLayout.grid;
  List<LibraryEntry> _entries = const [];
  static const _layoutKey = 'library_layout';

  void start() {
    _layout = _readLayout();
    _authSub ??= _watchAuthState().listen((user) {
      if (user == null) {
        unawaited(_librarySub?.cancel());
        _librarySub = null;
        _entries = const [];
        emit(LibraryLoaded(
          entries: const [],
          games: const [],
          filter: LibraryFilter.all,
          layout: _layout,
        ));
        return;
      }
      _listenLibrary();
    });
  }

  void _listenLibrary() {
    unawaited(_librarySub?.cancel());
    emit(LibraryLoading(filter: _filter, layout: _layout));
    _librarySub = _watchLibrary().listen(
      (entries) {
        _entries = entries;
        unawaited(_hydrate(entries));
      },
      onError: (Object error) {
        emit(LibraryError(_messageFrom(error), filter: _filter, layout: _layout));
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
          layout: _layout,
        ),
      );
    } catch (error) {
      if (isClosed) {
        return;
      }
      emit(LibraryError(_messageFrom(error), filter: _filter, layout: _layout));
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
          layout: _layout,
        ),
      );
      return;
    }
    emit(LibraryLoading(filter: filter, layout: _layout));
  }

  void toggleLayout() {
    _layout = _layout == LibraryLayout.grid
        ? LibraryLayout.list
        : LibraryLayout.grid;
    unawaited(_persistLayout());
    final current = state;
    if (current is LibraryLoaded) {
      emit(
        LibraryLoaded(
          entries: current.entries,
          games: current.games,
          filter: current.filter,
          layout: _layout,
        ),
      );
      return;
    }
    if (current is LibraryError) {
      emit(
        LibraryError(
          current.message,
          filter: current.filter,
          layout: _layout,
        ),
      );
      return;
    }
    emit(LibraryLoading(filter: _filter, layout: _layout));
  }

  LibraryLayout _readLayout() {
    try {
      final raw = Hive.box<dynamic>('game_cache').get(_layoutKey);
      return raw == LibraryLayout.list.name
          ? LibraryLayout.list
          : LibraryLayout.grid;
    } catch (_) {
      return LibraryLayout.grid;
    }
  }

  Future<void> _persistLayout() async {
    try {
      if (!Hive.isBoxOpen('game_cache')) {
        return;
      }
      await Hive.box<dynamic>('game_cache').put(_layoutKey, _layout.name);
    } catch (_) {}
  }

  Future<void> setStatus({
    required String gameId,
    required LibraryStatus status,
  }) async {
    try {
      final current = state.entryFor(gameId);
      if (current?.status == status) {
        await _removeGameFromLibrary(gameId);
        return;
      }
      await _setGameStatus(gameId: gameId, status: status);
    } catch (error) {
      emit(LibraryError(_messageFrom(error), filter: _filter, layout: _layout));
      emit(
        LibraryLoaded(
          entries: _entries,
          games: state is LibraryLoaded
              ? (state as LibraryLoaded).games
              : const [],
          filter: _filter,
          layout: _layout,
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
