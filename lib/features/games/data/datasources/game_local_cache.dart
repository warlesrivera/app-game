import '../../domain/models/game.dart';
import '../../domain/models/game_guide.dart';

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

  Future<List<Game>?> getCatalog(String catalogId);

  Future<void> saveCatalog({
    required String catalogId,
    required List<Game> games,
  });

  Future<GameGuide?> getGuide(String gameId);

  Future<void> saveGuide({
    required String gameId,
    required GameGuide guide,
  });
}
