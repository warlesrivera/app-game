import '../models/game.dart';

abstract interface class GameRepository {
  Future<List<Game>> getDiscoverGames({int page = 1});

  Future<List<Game>> searchGames(String query);

  Future<Game?> getGameById(String id);

  Future<List<Game>> getGamesByIds(List<String> ids);
}
