import '../../domain/models/game.dart';
import '../../domain/models/game_guide.dart';
import '../../domain/repositories/game_guide_repository.dart';
import '../datasources/game_local_cache.dart';
import '../datasources/wikipedia_guide_remote_datasource.dart';

class GameGuideRepositoryImpl implements GameGuideRepository {
  const GameGuideRepositoryImpl({
    required this.wikipedia,
    required this.localCache,
  });

  final WikipediaGuideRemoteDataSource wikipedia;
  final GameLocalCache localCache;

  @override
  Future<GameGuide> getGuide(Game game) async {
    final cached = await localCache.getGuide(game.id);
    if (cached != null) {
      return cached;
    }

    try {
      final wiki = await wikipedia.search(
        game.name,
        releaseYear: game.releaseDate?.year,
      );
      final guide = wiki ?? const GameGuide(sourceLabel: 'Wikipedia');
      await localCache.saveGuide(gameId: game.id, guide: guide);
      return guide;
    } catch (_) {
      return const GameGuide(sourceLabel: 'Wikipedia');
    }
  }
}
