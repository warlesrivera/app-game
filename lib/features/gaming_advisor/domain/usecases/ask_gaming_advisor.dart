import '../../../games/domain/usecases/get_games_by_ids.dart';
import '../../../library/domain/models/library_entry.dart';
import '../../../library/domain/models/library_game.dart';
import '../../../library/domain/usecases/watch_library.dart';
import '../advisor_logic.dart';
import '../gaming_context_builder.dart';
import '../local_recommendation_engine.dart';
import '../memory_extractor.dart';
import '../models/gaming_models.dart';
import '../repositories/gaming_advisor_repository.dart';

class AdvisorReply {
  const AdvisorReply({
    required this.text,
    this.cards = const [],
    this.memories = const [],
    this.summary,
  });

  final String text;
  final List<AdvisorRecommendation> cards;
  final List<GamingMemory> memories;
  final String? summary;
}

class AskGamingAdvisor {
  const AskGamingAdvisor({
    required GamingAdvisorRepository repository,
    required AIAdvisorService ai,
    required WatchLibrary watchLibrary,
    required GetGamesByIds getGamesByIds,
  }) : _repository = repository,
       _ai = ai,
       _watchLibrary = watchLibrary,
       _getGamesByIds = getGamesByIds;

  static const _system =
      'You are a personal videogame advisor. '
      'Use only the provided player profile, memories, game information and current context. '
      'Personalize answers using the player documented preferences. '
      'Do not invent player preferences. '
      'Do not claim the player likes or dislikes something unless supported by the provided context. '
      'Separate factual information about games from personalized recommendations. '
      'If information is missing, say that it is unknown. '
      'When comparing games, explain tradeoffs rather than inventing certainty. '
      'Answer in Spanish. Keep answers concise unless the user asks for detail.';

  final GamingAdvisorRepository _repository;
  final AIAdvisorService _ai;
  final WatchLibrary _watchLibrary;
  final GetGamesByIds _getGamesByIds;

  Future<AdvisorReply> call({
    required String question,
    required GamingProfile profile,
    required List<GamingMemory> memories,
    required List<AdvisorMessage> history,
    String? focusGameId,
  }) async {
    final library = await _library();
    final local = LocalQuestionResolver.resolve(
      question: question,
      library: library,
      profile: profile,
    );
    if (local != null) {
      return AdvisorReply(text: local);
    }

    final focus = _find(library, focusGameId);
    final context = GamingContextBuilder.build(
      question: question,
      profile: profile,
      memories: memories,
      library: library,
      history: history,
      focus: focus,
    );
    final wantsCards = RegExp(
      r'recom|compar|deberia|gustaria|jugar|compr',
    ).hasMatch(question.toLowerCase());
    final cards = wantsCards
        ? LocalRecommendationEngine.rank(
            question: question,
            profile: profile,
            library: library,
          )
        : const <AdvisorRecommendation>[];
    final cacheKey = AdvisorReplyCacheKey.of(question, context.fingerprint);
    final cached = _repository.readCachedReply(cacheKey);
    if (cached != null) {
      return AdvisorReply(text: cached, cards: cards);
    }

    String text;
    try {
      if (!_ai.isAvailable) {
        throw StateError('unavailable');
      }
      text = await _ai.ask(systemInstruction: _system, prompt: context.prompt());
      await _repository.writeCachedReply(cacheKey, text);
    } catch (_) {
      text = cards.isEmpty
          ? 'No pude consultar el asistente ahora.'
          : 'No pude consultar el asistente ahora. Según tu perfil y tu biblioteca, estas son las opciones más relevantes:';
    }

    final extracted = MemoryExtractor.extract(question: question, existing: memories);
    final summary = history.length >= 6 && history.length % 6 == 0
        ? _summary(history, profile)
        : null;
    return AdvisorReply(
      text: text,
      cards: cards,
      memories: extracted,
      summary: summary,
    );
  }

  Future<List<LibraryGame>> _library() async {
    List<LibraryEntry> entries;
    try {
      entries = await _watchLibrary().first.timeout(
        const Duration(seconds: 2),
        onTimeout: () => const <LibraryEntry>[],
      );
    } catch (_) {
      return const [];
    }
    if (entries.isEmpty) {
      return const [];
    }
    try {
      final games = await _getGamesByIds([
        for (final entry in entries) entry.gameId,
      ]);
      final byId = {for (final game in games) game.id: game};
      return [
        for (final entry in entries)
          if (byId[entry.gameId] != null)
            LibraryGame(game: byId[entry.gameId]!, entry: entry),
      ];
    } catch (_) {
      return const [];
    }
  }

  LibraryGame? _find(List<LibraryGame> library, String? id) {
    if (id == null) {
      return null;
    }
    for (final item in library) {
      if (item.game.id == id) {
        return item;
      }
    }
    return null;
  }

  String _summary(List<AdvisorMessage> history, GamingProfile profile) {
    final recent = history.where((message) => message.isUser).take(4);
    final topics = recent.map((message) => message.text).join(' ');
    final current = profile.currentGameId ?? 'sin juego actual';
    return 'Juego actual: $current. Preguntas recientes: $topics';
  }
}

abstract final class AdvisorReplyCacheKey {
  static String of(String question, String fingerprint) {
    final normalized = question.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
    return '$normalized|$fingerprint';
  }
}
