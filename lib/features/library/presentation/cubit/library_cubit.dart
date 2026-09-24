import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/domain/usecases/watch_auth_state.dart';
import '../../../games/domain/usecases/get_games_by_ids.dart';
import '../../../prices/domain/models/game_deal.dart';
import '../../../prices/domain/usecases/get_game_deal.dart';
import '../../../prices/domain/usecases/save_price_alert.dart';
import '../../../prices/data/wishlist_price_snapshot.dart';
import '../../domain/models/library_entry.dart';
import '../../domain/models/library_game.dart';
import '../../domain/models/library_status.dart';
import '../../domain/usecases/remove_game_from_library.dart';
import '../../domain/usecases/set_favorite_rank.dart';
import '../../domain/usecases/set_game_favorite.dart';
import '../../domain/usecases/set_game_status.dart';
import '../../domain/usecases/watch_library.dart';
import 'library_state.dart';

class LibraryCubit extends Cubit<LibraryState> {
  LibraryCubit({
    required WatchAuthState watchAuthState,
    required WatchLibrary watchLibrary,
    required SetGameStatus setGameStatus,
    required RemoveGameFromLibrary removeGameFromLibrary,
    required SetGameFavorite setGameFavorite,
    required SetFavoriteRank setFavoriteRank,
    required GetGamesByIds getGamesByIds,
    required SavePriceAlert savePriceAlert,
    required GetGameDeal getGameDeal,
  }) : _watchAuthState = watchAuthState,
       _watchLibrary = watchLibrary,
       _setGameStatus = setGameStatus,
       _removeGameFromLibrary = removeGameFromLibrary,
       _setGameFavorite = setGameFavorite,
       _setFavoriteRank = setFavoriteRank,
       _getGamesByIds = getGamesByIds,
       _savePriceAlert = savePriceAlert,
       _getGameDeal = getGameDeal,
       super(const LibraryInitial());

  final WatchAuthState _watchAuthState;
  final WatchLibrary _watchLibrary;
  final SetGameStatus _setGameStatus;
  final RemoveGameFromLibrary _removeGameFromLibrary;
  final SetGameFavorite _setGameFavorite;
  final SetFavoriteRank _setFavoriteRank;
  final GetGamesByIds _getGamesByIds;
  final SavePriceAlert _savePriceAlert;
  final GetGameDeal _getGameDeal;

  StreamSubscription<AppUser?>? _authSub;
  StreamSubscription<List<LibraryEntry>>? _librarySub;
  LibraryFilter _filter = LibraryFilter.all;
  LibraryLayout _layout = LibraryLayout.grid;
  List<LibraryEntry> _entries = const [];
  Map<String, GameDeal?> _deals = const {};
  int _dealToken = 0;
  static const _layoutKey = 'library_layout';
  static const _dealBatchSize = 4;

  void start() {
    _layout = _readLayout();
    _authSub ??= _watchAuthState().listen((user) {
      if (user == null) {
        unawaited(_librarySub?.cancel());
        _librarySub = null;
        _entries = const [];
        _deals = const {};
        _dealToken += 1;
        unawaited(_clearPriceWatch());
        emit(
          LibraryLoaded(
            entries: const [],
            games: const [],
            filter: LibraryFilter.all,
            layout: _layout,
          ),
        );
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
        emit(
          LibraryError(_messageFrom(error), filter: _filter, layout: _layout),
        );
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
      emit(_loaded(entries: entries, games: hydrated));
      unawaited(_syncPriceWatch(hydrated));
      unawaited(_loadWishlistDeals(hydrated));
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
      emit(current.copyWith(filter: filter, layout: _layout));
      unawaited(_loadWishlistDeals(current.games));
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
      emit(current.copyWith(layout: _layout));
      return;
    }
    if (current is LibraryError) {
      emit(
        LibraryError(current.message, filter: current.filter, layout: _layout),
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

  Future<void> _syncPriceWatch(List<LibraryGame> games) async {
    if (!Hive.isBoxOpen(WishlistPriceSnapshot.boxName)) {
      return;
    }
    await WishlistPriceSnapshot(
      Hive.box<dynamic>(WishlistPriceSnapshot.boxName),
    ).sync(games);
  }

  Future<void> _clearPriceWatch() async {
    if (!Hive.isBoxOpen(WishlistPriceSnapshot.boxName)) {
      return;
    }
    await WishlistPriceSnapshot(
      Hive.box<dynamic>(WishlistPriceSnapshot.boxName),
    ).clear();
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
        _loaded(
          entries: _entries,
          games: state is LibraryLoaded
              ? (state as LibraryLoaded).games
              : const [],
        ),
      );
    }
  }

  Future<void> setFavorite({
    required String gameId,
    required bool isFavorite,
  }) async {
    try {
      await _setGameFavorite(gameId: gameId, isFavorite: isFavorite);
    } catch (error) {
      emit(LibraryError(_messageFrom(error), filter: _filter, layout: _layout));
      if (_entries.isNotEmpty || state is LibraryLoaded) {
        emit(
          _loaded(
            entries: _entries,
            games: state is LibraryLoaded
                ? (state as LibraryLoaded).games
                : const [],
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> reorderFavorites(List<String> gameIds) async {
    if (gameIds.isEmpty) {
      return;
    }
    _applyLocalFavoriteOrder(gameIds);
    try {
      await _setFavoriteRank.reorder(gameIds);
    } catch (error) {
      emit(LibraryError(_messageFrom(error), filter: _filter, layout: _layout));
      if (_entries.isNotEmpty || state is LibraryLoaded) {
        emit(
          _loaded(
            entries: _entries,
            games: state is LibraryLoaded
                ? (state as LibraryLoaded).games
                : const [],
          ),
        );
      }
      rethrow;
    }
  }

  void _applyLocalFavoriteOrder(List<String> gameIds) {
    final current = state;
    if (current is! LibraryLoaded) {
      return;
    }
    final rankById = {
      for (var index = 0; index < gameIds.length; index += 1)
        gameIds[index]: index + 1,
    };
    final games = [
      for (final item in current.games)
        LibraryGame(
          game: item.game,
          entry: item.entry.copyWith(
            favoriteRank: rankById[item.game.id],
            clearFavoriteRank:
                item.entry.isFavorite && !rankById.containsKey(item.game.id),
          ),
        ),
    ];
    final entries = [
      for (final entry in current.entries)
        entry.copyWith(
          favoriteRank: rankById[entry.gameId],
          clearFavoriteRank:
              entry.isFavorite && !rankById.containsKey(entry.gameId),
        ),
    ];
    _entries = entries;
    emit(current.copyWith(entries: entries, games: games));
  }

  Future<void> setFavoriteRank({required String gameId, int? rank}) async {
    try {
      final current = state.favoriteGames;
      if (current.isNotEmpty) {
        final ids = [for (final item in current) item.game.id]..remove(gameId);
        if (rank == null) {
          ids.add(gameId);
        } else {
          ids.insert((rank - 1).clamp(0, ids.length), gameId);
        }
        _applyLocalFavoriteOrder(ids);
      }
      await _setFavoriteRank(gameId: gameId, rank: rank);
    } catch (error) {
      emit(LibraryError(_messageFrom(error), filter: _filter, layout: _layout));
      if (_entries.isNotEmpty || state is LibraryLoaded) {
        emit(
          _loaded(
            entries: _entries,
            games: state is LibraryLoaded
                ? (state as LibraryLoaded).games
                : const [],
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> savePriceAlert({
    required String gameId,
    required bool enabled,
    required List<String> stores,
  }) {
    return _savePriceAlert(gameId: gameId, enabled: enabled, stores: stores);
  }

  Future<void> retry() async {
    _listenLibrary();
  }

  LibraryLoaded _loaded({
    required List<LibraryEntry> entries,
    required List<LibraryGame> games,
  }) {
    return LibraryLoaded(
      entries: entries,
      games: games,
      filter: _filter,
      layout: _layout,
      deals: _deals,
      loadingDealIds: state is LibraryLoaded
          ? (state as LibraryLoaded).loadingDealIds
          : const {},
    );
  }

  Future<void> _loadWishlistDeals(List<LibraryGame> games) async {
    final pending = [
      for (final item in games)
        if (item.entry.status == LibraryStatus.wishlist &&
            !_deals.containsKey(item.game.id))
          item,
    ];
    if (pending.isEmpty) {
      return;
    }

    final token = ++_dealToken;
    final loadingIds = {for (final item in pending) item.game.id};
    final current = state;
    if (current is LibraryLoaded) {
      emit(
        current.copyWith(
          loadingDealIds: {...current.loadingDealIds, ...loadingIds},
        ),
      );
    }

    for (var index = 0; index < pending.length; index += _dealBatchSize) {
      if (isClosed || token != _dealToken) {
        return;
      }
      final end = index + _dealBatchSize > pending.length
          ? pending.length
          : index + _dealBatchSize;
      final chunk = pending.sublist(index, end);
      final results = await Future.wait(
        chunk.map((item) async {
          try {
            return MapEntry(item.game.id, await _getGameDeal(item.game.name));
          } catch (_) {
            return MapEntry<String, GameDeal?>(item.game.id, null);
          }
        }),
      );
      if (isClosed || token != _dealToken) {
        return;
      }
      final latest = state;
      if (latest is! LibraryLoaded) {
        continue;
      }
      final deals = Map<String, GameDeal?>.from(_deals);
      final loading = Set<String>.from(latest.loadingDealIds);
      for (final result in results) {
        deals[result.key] = result.value;
        loading.remove(result.key);
      }
      _deals = deals;
      emit(latest.copyWith(deals: deals, loadingDealIds: loading));
    }
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
