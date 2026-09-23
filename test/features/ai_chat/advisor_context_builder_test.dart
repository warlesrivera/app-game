import 'package:flutter_test/flutter_test.dart';
import 'package:gamevault/features/ai_chat/domain/advisor_context_builder.dart';
import 'package:gamevault/features/ai_chat/domain/models/advisor_limits.dart';
import 'package:gamevault/features/games/domain/models/game.dart';
import 'package:gamevault/features/library/domain/models/library_entry.dart';
import 'package:gamevault/features/library/domain/models/library_status.dart';

void main() {
  const focus = Game(id: 'dd2', name: "Dragon's Dogma 2");

  LibraryEntry entry(
    String id,
    LibraryStatus status, {
    bool favorite = false,
    int? rank,
  }) {
    return LibraryEntry(
      gameId: id,
      status: status,
      isFavorite: favorite,
      favoriteRank: rank,
      updatedAt: DateTime(2026, 1, 1),
    );
  }

  final entries = [
    entry('mgs4', LibraryStatus.playing),
    entry('som', LibraryStatus.completed, favorite: true, rank: 1),
    entry('onimusha', LibraryStatus.completed, favorite: true, rank: 2),
    entry('lies', LibraryStatus.completed),
    entry('dos2', LibraryStatus.abandoned),
    entry('kh3', LibraryStatus.wishlist),
    entry('witcher', LibraryStatus.wishlist),
    for (var i = 0; i < 20; i++) entry('extra$i', LibraryStatus.completed),
  ];

  final games = <String, Game>{
    for (final item in entries) item.gameId: Game(id: item.gameId, name: item.gameId),
    focus.id: focus,
  };

  test('no manda toda la biblioteca en una pregunta general', () {
    final ids = AdvisorContextBuilder.hydrateIds(
      question: '¿cómo empiezo este juego?',
      focusId: focus.id,
      entries: entries,
    );

    expect(ids, contains(focus.id));
    expect(ids.length, lessThanOrEqualTo(AdvisorLimits.maxRelevantGames + 1));
    expect(ids.where((id) => id.startsWith('extra')).length, lessThanOrEqualTo(2));
  });

  test('una pregunta de recomendación incluye wishlist y abandonados, no extras', () {
    final context = AdvisorContextBuilder.build(
      question: '¿qué debería jugar después?',
      focus: focus,
      entries: entries,
      games: games,
    );

    expect(context.playing, contains('mgs4'));
    expect(context.favorites, contains('som'));
    expect(context.wishlist, isNotEmpty);
    expect(context.abandoned, contains('dos2'));
    expect(context.completed.length, lessThanOrEqualTo(2));
    expect(context.compactLine.contains('extra'), isFalse);
  });

  test('cuántos juegos es una pregunta factual de estado', () {
    expect(
      AdvisorContextBuilder.intentOf('¿cuántos juegos completados tengo?'),
      AdvisorIntent.status,
    );
  });
}
