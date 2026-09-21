import '../../domain/ai_error.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/game_ai_context.dart';
import '../../domain/repositories/game_ai_repository.dart';
import '../datasources/ai_chat_remote_datasource.dart';
import '../providers/gemini_ai_provider.dart';

class GameAIRepositoryImpl implements GameAIRepository {
  const GameAIRepositoryImpl({
    required AiChatRemoteDataSource remote,
    required GeminiAiProvider provider,
  }) : _remote = remote,
       _provider = provider;

  final AiChatRemoteDataSource _remote;
  final GeminiAiProvider _provider;

  @override
  bool get isAvailable => _provider.isAvailable;

  @override
  Stream<List<ChatMessage>> watchMessages({required String gameId}) {
    return _remote.watchMessages(gameId);
  }

  @override
  Future<String> sendMessage({
    required String gameId,
    required String gameName,
    required String message,
    GameAiContext? gameContext,
    List<ChatMessage> history = const [],
  }) async {
    await _remote.ensureChat(gameId: gameId, gameName: gameName);
    await _remote.addMessage(
      gameId: gameId,
      role: ChatRole.user,
      text: message,
    );

    try {
      final reply = await _provider.generate(
        gameName: gameName,
        message: message,
        gameContext: gameContext,
        history: history,
      );
      await _remote.addMessage(
        gameId: gameId,
        role: ChatRole.assistant,
        text: reply,
      );
      return reply;
    } catch (error) {
      if (error is StateError) {
        rethrow;
      }
      throw StateError(friendlyAiError(error));
    }
  }
}
