import '../../domain/ai_error.dart';
import '../../domain/local_advisor_resolver.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/game_ai_context.dart';
import '../../domain/models/player_vault_context.dart';
import '../../domain/repositories/game_ai_repository.dart';
import '../datasources/advisor_reply_cache.dart';
import '../datasources/ai_chat_remote_datasource.dart';
import '../providers/gemini_ai_provider.dart';

class GameAIRepositoryImpl implements GameAIRepository {
  const GameAIRepositoryImpl({
    required AiChatRemoteDataSource remote,
    required GeminiAiProvider provider,
    required AdvisorReplyCache cache,
  }) : _remote = remote,
       _provider = provider,
       _cache = cache;

  final AiChatRemoteDataSource _remote;
  final GeminiAiProvider _provider;
  final AdvisorReplyCache _cache;

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
    PlayerVaultContext? vault,
    List<ChatMessage> history = const [],
  }) async {
    await _remote.ensureChat(gameId: gameId, gameName: gameName);
    await _remote.addMessage(
      gameId: gameId,
      role: ChatRole.user,
      text: message,
    );

    try {
      if (vault != null) {
        final local = LocalAdvisorResolver.resolve(
          question: message,
          vault: vault,
          game: gameContext,
        );
        if (local != null) {
          await _remote.addMessage(
            gameId: gameId,
            role: ChatRole.assistant,
            text: local,
          );
          return local;
        }
      }

      final cacheKey = vault == null
          ? null
          : AdvisorReplyCache.keyFor(
              question: message,
              fingerprint: vault.fingerprint,
            );
      if (cacheKey != null) {
        final cached = _cache.read(cacheKey);
        if (cached != null) {
          await _remote.addMessage(
            gameId: gameId,
            role: ChatRole.assistant,
            text: cached,
          );
          return cached;
        }
      }

      final reply = await _provider.generate(
        gameName: gameName,
        message: message,
        gameContext: gameContext,
        vault: vault,
        history: history,
      );
      if (cacheKey != null) {
        await _cache.write(cacheKey, reply);
      }
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

  @override
  Future<String?> generatePlayerProfile({
    required int completed,
    required int abandoned,
    required int playing,
    required String favoriteGenre,
    required List<String> topFavorites,
    required Map<String, int> genreCounts,
  }) {
    return _provider.generatePlayerProfile(
      completed: completed,
      abandoned: abandoned,
      playing: playing,
      favoriteGenre: favoriteGenre,
      topFavorites: topFavorites,
      genreCounts: genreCounts,
    );
  }
}
