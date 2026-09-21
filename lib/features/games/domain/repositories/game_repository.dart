import '../models/game.dart';
import '../models/game_video.dart';

abstract interface class GameRepository {
  Future<List<Game>> getDiscoverGames({int page = 1});

  Future<List<Game>> searchGames(String query);

  Future<Game?> getGameById(String id);

  Future<Game> getGameDetails(int id);

  Future<List<GameVideo>> getGameVideos(int id);

  Future<List<Game>> getGamesByIds(List<String> ids);

  Future<List<Game>> getCatalog({
    required String catalogId,
    int? parentPlatforms,
    String? platforms,
    String ordering = '-added',
    String? dates,
    int page = 1,
  });

  Future<void> cacheGame(Game game);
}
