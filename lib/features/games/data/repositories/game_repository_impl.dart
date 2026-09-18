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
}
