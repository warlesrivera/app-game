import '../models/chat_message.dart';

abstract class GameAIRepository {
  bool get isAvailable;

  Stream<List<ChatMessage>> watchMessages({required String gameId});

  Future<String> sendMessage({
    required String gameId,
    required String gameName,
    required String message,
  });
}
