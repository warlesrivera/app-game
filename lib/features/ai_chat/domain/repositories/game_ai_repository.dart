import '../models/chat_message.dart';
import '../models/game_ai_context.dart';

abstract class GameAIRepository {
  bool get isAvailable;

  Stream<List<ChatMessage>> watchMessages({required String gameId});

  Future<String> sendMessage({
    required String gameId,
    required String gameName,
    required String message,
    GameAiContext? gameContext,
    List<ChatMessage> history,
  });

  Future<String?> generatePlayerProfile({
    required int completed,
    required int abandoned,
    required int playing,
    required String favoriteGenre,
    required List<String> topFavorites,
    required Map<String, int> genreCounts,
  });
}
