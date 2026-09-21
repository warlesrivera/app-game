import '../../../ai_chat/data/providers/gemini_ai_provider.dart';
import '../models/game.dart';
import '../repositories/game_repository.dart';

class TranslateGameDescription {
  const TranslateGameDescription({
    required GeminiAiProvider gemini,
    required GameRepository gameRepository,
  }) : _gemini = gemini,
       _gameRepository = gameRepository;

  final GeminiAiProvider _gemini;
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
    if (!_gemini.isAvailable) {
      return game;
    }

    final translated = await _gemini.translateToSpanish(source);
    if (translated == null || translated.trim().isEmpty) {
      return game;
    }

    final updated = game.copyWith(descriptionEs: translated.trim());
    await _gameRepository.cacheGame(updated);
    return updated;
  }
}
