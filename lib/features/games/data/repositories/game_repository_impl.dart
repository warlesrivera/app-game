import '../../domain/models/game.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/game_local_cache.dart';
import '../datasources/rawg_remote_datasource.dart';

class GameRepositoryImpl implements GameRepository {
  const GameRepositoryImpl({
    required this.remoteDataSource,
    required this.localCache,
  });

  final RawgRemoteDataSource remoteDataSource;
  final GameLocalCache localCache;

  @override
  Future<List<Game>> getDiscoverGames({int page = 1}) async {
    final cached = await localCache.getDiscoverGames(page: page);
    if (cached != null) {
      return cached;
    }

    final remote = await remoteDataSource.getDiscoverGames(page: page);
    await localCache.saveDiscoverGames(page: page, games: remote);
    return remote;
  }

  @override
  Future<List<Game>> searchGames(String query) async {
    final cached = await localCache.getSearchGames(query: query);
    if (cached != null) {
      return cached;
    }

    final remote = await remoteDataSource.searchGames(query);
    await localCache.saveSearchGames(query: query, games: remote);
    return remote;
  }

  @override
  Future<Game?> getGameById(String id) async {
    final cached = await localCache.getGame(id);
    if (cached != null) {
      return cached;
    }

    try {
      final remote = await remoteDataSource.getGameById(id);
      await localCache.saveGame(remote);
      return remote;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Game> getGameDetails(int id) async {
    final cached = await localCache.getGame('$id');
    final remote = await remoteDataSource.getGameDetails(id);
    final mergedShots = <String>[];
    final seen = <String>{};
    for (final url in [
      ...remote.screenshotUrls,
      ...?cached?.screenshotUrls,
    ]) {
      if (url.isNotEmpty && seen.add(url)) {
        mergedShots.add(url);
      }
    }

    final merged = cached == null
        ? remote.copyWith(screenshotUrls: mergedShots)
        : remote.copyWith(
            coverUrl: cached.coverUrl ?? remote.coverUrl,
            name: cached.name.isNotEmpty ? cached.name : remote.name,
            screenshotUrls: mergedShots,
            descriptionEs: cached.descriptionEs ?? remote.descriptionEs,
          );
    await localCache.saveGame(merged);
    return merged;
  }

  @override
  Future<List<Game>> getGamesByIds(List<String> ids) async {
    final games = <Game>[];
    for (final id in ids) {
      final game = await getGameById(id);
      if (game != null) {
        games.add(game);
      }
    }
    return games;
  }

  @override
  Future<List<Game>> getCatalog({
    required String catalogId,
    int? parentPlatforms,
    String? platforms,
    String ordering = '-added',
    String? dates,
    int page = 1,
    int pageSize = 40,
  }) async {
    final cacheId = '$catalogId-p$page-s$pageSize';
    final cached = await localCache.getCatalog(cacheId);
    if (cached != null) {
      return cached;
    }

    final remote = await remoteDataSource.getCatalog(
      catalogId: catalogId,
      parentPlatforms: parentPlatforms,
      platforms: platforms,
      ordering: ordering,
      dates: dates,
      page: page,
      pageSize: pageSize,
    );
    await localCache.saveCatalog(catalogId: cacheId, games: remote);
    return remote;
  }

  @override
  Future<void> cacheGame(Game game) {
    return localCache.saveGame(game);
  }
}
