import '../models/chat_message.dart';
import '../repositories/game_ai_repository.dart';

class WatchAiMessages {
  const WatchAiMessages(this._repository);

  final GameAIRepository _repository;

  Stream<List<ChatMessage>> call(String gameId) {
    return _repository.watchMessages(gameId: gameId);
  }
}
