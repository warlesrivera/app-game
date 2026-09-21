import '../models/game.dart';
import '../repositories/game_repository.dart';
import '../repositories/game_translator.dart';

class TranslateGameDescription {
  const TranslateGameDescription({
    required GameTranslator translator,
    required GameRepository gameRepository,
  }) : _translator = translator,
       _gameRepository = gameRepository;

  final GameTranslator _translator;
  final GameRepository _gameRepository;

  Future<Game> call(Game game) async {
    final source = game.description?.trim();
    if (source == null || source.isEmpty) {
      return game;
    }
    final existing = game.descriptionEs?.trim();
    if (existing != null && existing.isNotEmpty) {
      return game;
    }

    final translated = await _translator.translateToSpanish(source);
    if (translated == null || translated.trim().isEmpty) {
      return game;
    }

    final updated = game.copyWith(descriptionEs: translated.trim());
    await _gameRepository.cacheGame(updated);
    return updated;
  }
}
