import 'package:flutter_test/flutter_test.dart';
import 'package:gamevault/features/games/domain/models/game.dart';
import 'package:gamevault/features/gaming_advisor/domain/advisor_logic.dart';
import 'package:gamevault/features/gaming_advisor/domain/gaming_context_builder.dart';
import 'package:gamevault/features/gaming_advisor/domain/local_recommendation_engine.dart';
import 'package:gamevault/features/gaming_advisor/domain/memory_extractor.dart';
import 'package:gamevault/features/gaming_advisor/domain/models/gaming_models.dart';
import 'package:gamevault/features/library/domain/models/library_entry.dart';
import 'package:gamevault/features/library/domain/models/library_game.dart';
import 'package:gamevault/features/library/domain/models/library_status.dart';

void main() {
  LibraryGame game(String id, LibraryStatus status, {List<String> genres = const []}) {
    return LibraryGame(
      game: Game(id: id, name: id, genres: genres),
      entry: LibraryEntry(gameId: id, status: status),
    );
  }

  final library = [
    game('mgs4', LibraryStatus.playing, genres: const ['Action']),
    game('som', LibraryStatus.completed, genres: const ['Action']),
    game('dos2', LibraryStatus.abandoned, genres: const ['RPG']),
    game('dd2', LibraryStatus.wishlist, genres: const ['Action', 'RPG']),
    game('kh3', LibraryStatus.wishlist),
    for (var i = 0; i < 20; i++) game('extra$i', LibraryStatus.completed),
  ];

  test('el contexto no envía toda la biblioteca', () {
    final context = GamingContextBuilder.build(
      question: '¿Me gustaría Dragon Dogma?',
      profile: const GamingProfile(currentGameId: 'mgs4'),
      memories: [
        for (var i = 0; i < 20; i++)
          GamingMemory(
            id: 'm$i',
            category: MemoryCategory.preference,
            content: i == 0 ? 'Prefiere combate de acción' : 'memoria irrelevante $i',
          ),
      ],
      library: library,
      history: const [],
    );

    expect(context.games.length, lessThanOrEqualTo(AdvisorBudget.maxRelevantGames));
    expect(context.memories.length, lessThanOrEqualTo(AdvisorBudget.maxRelevantMemories));
    expect(context.games.length, lessThan(library.length));
    expect(context.prompt().contains('extra0'), isFalse);
  });

  test('las recomendaciones excluyen completados y abandonados', () {
    final cards = LocalRecommendationEngine.rank(
      question: '¿Qué debería jugar?',
      profile: const GamingProfile(combatImportance: 5),
      library: library,
    );
    expect(cards.map((card) => card.gameId), isNot(contains('som')));
    expect(cards.map((card) => card.gameId), isNot(contains('dos2')));
    expect(cards.length, lessThanOrEqualTo(5));
    expect(cards.first.reasons, isNotEmpty);
  });

  test('la memoria no se duplica y las preguntas factuales no crean memoria', () {
    final existing = [
      const GamingMemory(
        id: '1',
        category: MemoryCategory.preference,
        content: 'Me gusta el combate de accion',
        confidence: 0.7,
      ),
    ];
    final updated = MemoryExtractor.extract(
      question: 'Me gusta el combate de accion',
      existing: existing,
    );
    expect(updated.single.id, '1');
    expect(updated.single.confidence, greaterThan(0.7));

    final factual = MemoryExtractor.extract(
      question: '¿Cuánto dura MGS4?',
      existing: existing,
    );
    expect(factual, isEmpty);
  });

  test('las fechas de lanzamiento se resuelven sin Gemini', () {
    final dated = LibraryGame(
      game: Game(
        id: 'wilds',
        name: 'Monster Hunter Wilds',
        releaseDate: DateTime(2026, 2, 28),
      ),
      entry: const LibraryEntry(gameId: 'wilds', status: LibraryStatus.wishlist),
    );
    final answer = LocalQuestionResolver.resolve(
      question: '¿Cuándo sale Monster Hunter Wilds?',
      library: [dated],
      profile: const GamingProfile(),
    );
    expect(answer, contains('28/2/2026'));
  });

  test('la timeline sale de la biblioteca', () {
    final stops = GamingViews.timeline(library);
    expect(stops.where((stop) => stop.lane == 'Completados'), isNotEmpty);
    expect(stops.where((stop) => stop.lane == 'Jugando').single.title, 'mgs4');
  });
}
