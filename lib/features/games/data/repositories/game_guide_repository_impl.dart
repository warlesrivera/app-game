import '../../../ai_chat/data/providers/gemini_ai_provider.dart';
import '../../domain/models/game.dart';
import '../../domain/models/game_guide.dart';
import '../../domain/repositories/game_guide_repository.dart';
import '../datasources/game_local_cache.dart';
import '../datasources/wikipedia_guide_remote_datasource.dart';

class GameGuideRepositoryImpl implements GameGuideRepository {
  const GameGuideRepositoryImpl({
    required this.wikipedia,
    required this.localCache,
    required this.gemini,
  });

  final WikipediaGuideRemoteDataSource wikipedia;
  final GameLocalCache localCache;
  final GeminiAiProvider gemini;

  @override
  Future<GameGuide> getGuide(Game game) async {
    final cached = await localCache.getGuide(game.id);
    if (cached != null && !cached.isEmpty) {
      return _withLinks(cached, game);
    }

    final wiki = await wikipedia.search(game.name);
    var guide = _withLinks(wiki ?? const GameGuide(), game);

    if (!guide.hasText && gemini.isAvailable) {
      try {
        final generated = await gemini.generateStarterGuide(game.name);
        if (generated != null && generated.trim().isNotEmpty) {
          guide = GameGuide(
            summary: generated.trim(),
            sourceLabel: 'GameVault',
            wikiUrl: guide.wikiUrl,
            walkthroughUrl: guide.walkthroughUrl,
            ignUrl: guide.ignUrl,
            redditUrl: guide.redditUrl,
          );
        }
      } catch (_) {}
    }

    if (!guide.isEmpty) {
      await localCache.saveGuide(gameId: game.id, guide: guide);
    }
    return guide;
  }

  GameGuide _withLinks(GameGuide guide, Game game) {
    final encoded = Uri.encodeQueryComponent(game.name);
    return GameGuide(
      summary: guide.summary,
      sourceLabel: guide.sourceLabel,
      wikiUrl: guide.wikiUrl,
      walkthroughUrl:
          guide.walkthroughUrl ??
          'https://gamefaqs.gamespot.com/search?game=$encoded',
      ignUrl: guide.ignUrl ?? 'https://www.ign.com/search?q=$encoded',
      redditUrl: guide.redditUrl ?? game.redditUrl,
    );
  }
}
