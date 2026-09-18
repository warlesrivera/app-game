import '../../domain/models/game.dart';

abstract interface class GameLocalCache {
  Future<List<Game>?> getDiscoverGames({required int page});

  Future<void> saveDiscoverGames({
    required int page,
    required List<Game> games,
  });

  Future<List<Game>?> getSearchGames({required String query});

  Future<void> saveSearchGames({
    required String query,
    required List<Game> games,
  });

  Future<Game?> getGame(String id);

  Future<void> saveGame(Game game);
}
