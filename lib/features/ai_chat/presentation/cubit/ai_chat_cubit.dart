import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../games/domain/models/game.dart';
import '../../domain/ai_error.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/game_ai_context.dart';
import '../../domain/usecases/send_ai_message.dart';
import '../../domain/usecases/watch_ai_messages.dart';
import 'ai_chat_state.dart';

class AiChatCubit extends Cubit<AiChatState> {
  AiChatCubit({
    required Game game,
    required SendAiMessage sendAiMessage,
    required WatchAiMessages watchAiMessages,
  }) : gameId = game.id,
       gameName = game.name,
       _gameContext = GameAiContext.fromGame(game),
       _sendAiMessage = sendAiMessage,
       _watchAiMessages = watchAiMessages,
       super(const AiChatInitial()) {
    _subscription = _watchAiMessages(gameId).listen(
      (messages) {
        emit(
          AiChatReady(
            messages: messages,
            sending: _sending,
            error: _error,
          ),
        );
      },
      onError: (_) {
        _error = 'No se pudo cargar el chat.';
        emit(
          AiChatReady(
            messages: const [],
            sending: false,
            error: _error,
          ),
        );
      },
    );
  }

  final String gameId;
  final String gameName;
  final GameAiContext _gameContext;
  final SendAiMessage _sendAiMessage;
  final WatchAiMessages _watchAiMessages;
  StreamSubscription<List<ChatMessage>>? _subscription;
  var _sending = false;
  String? _error;

  bool get isAvailable => _sendAiMessage.isAvailable;

  Future<void> send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || _sending) {
      return;
    }

    _sending = true;
    _error = null;
    final current = state;
    final prior = current is AiChatReady ? current.messages : const <ChatMessage>[];
    final optimistic = [
      ...prior,
      ChatMessage(
        id: 'local-${DateTime.now().millisecondsSinceEpoch}',
        role: ChatRole.user,
        text: text,
        createdAt: DateTime.now(),
      ),
    ];
    emit(AiChatReady(messages: optimistic, sending: true));

    try {
      if (!isAvailable) {
        throw StateError(
          'Configura GEMINI_API_KEY en .env para usar el asistente.',
        );
      }
      await _sendAiMessage(
        gameId: gameId,
        gameName: gameName,
        message: text,
        gameContext: _gameContext,
        history: prior,
      );
      _error = null;
    } catch (error) {
      debugPrint('AI chat send failed: $error');
      _sending = false;
      _error = friendlyAiError(error);
      emit(
        AiChatReady(
          messages: optimistic,
          sending: false,
          error: _error,
        ),
      );
      return;
    }

    _sending = false;
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
