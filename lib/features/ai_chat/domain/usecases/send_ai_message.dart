import '../models/chat_message.dart';
import '../models/game_ai_context.dart';
import '../repositories/game_ai_repository.dart';

class SendAiMessage {
  const SendAiMessage(this._repository);

  final GameAIRepository _repository;

  bool get isAvailable => _repository.isAvailable;

  Future<String> call({
    required String gameId,
    required String gameName,
    required String message,
    GameAiContext? gameContext,
    List<ChatMessage> history = const [],
  }) {
    return _repository.sendMessage(
      gameId: gameId,
      gameName: gameName,
      message: message,
      gameContext: gameContext,
      history: history,
    );
  }
}
