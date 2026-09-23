import 'package:flutter_test/flutter_test.dart';
import 'package:gamevault/features/ai_chat/domain/local_advisor_resolver.dart';
import 'package:gamevault/features/ai_chat/domain/models/game_ai_context.dart';
import 'package:gamevault/features/ai_chat/domain/models/player_vault_context.dart';
import 'package:gamevault/features/library/domain/models/library_game.dart';

void main() {
  const vault = PlayerVaultContext(
    focusId: 'mgs4',
    focusName: 'MGS4',
    focusStatus: 'Jugando',
    playing: ['MGS4'],
    favorites: ['Shadow of Mordor'],
    completed: ['Onimusha'],
    abandoned: ['Divinity OS2'],
    wishlist: ["Dragon's Dogma 2"],
    stats: LibraryStats(
      playing: 1,
      completed: 12,
      wishlist: 4,
      abandoned: 2,
    ),
  );

  test('cuenta completados sin Gemini', () {
    final reply = LocalAdvisorResolver.resolve(
      question: '¿cuántos juegos completados tengo?',
      vault: vault,
    );
    expect(reply, 'Tienes 12 juegos completados.');
  });

  test('dice el juego actual', () {
    final reply = LocalAdvisorResolver.resolve(
      question: '¿qué estoy jugando?',
      vault: vault,
    );
    expect(reply, 'Estás jugando MGS4.');
  });

  test('no intercepta una recomendación', () {
    final reply = LocalAdvisorResolver.resolve(
      question: '¿me gustaría Dragon’s Dogma 2?',
      vault: vault,
    );
    expect(reply, isNull);
  });

  test('confirma si el juego de la ficha está en la biblioteca', () {
    final reply = LocalAdvisorResolver.resolve(
      question: '¿tengo este juego?',
      vault: vault,
      game: const GameAiContext(name: 'MGS4', year: 2008),
    );
    expect(reply, contains('Jugando'));
  });
}
