import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/chat_message.dart';
import '../../domain/usecases/send_ai_message.dart';
import '../../domain/usecases/watch_ai_messages.dart';
import 'ai_chat_state.dart';

class AiChatCubit extends Cubit<AiChatState> {
  AiChatCubit({
    required this.gameId,
    required this.gameName,
    required SendAiMessage sendAiMessage,
    required WatchAiMessages watchAiMessages,
  }) : _sendAiMessage = sendAiMessage,
       _watchAiMessages = watchAiMessages,
       super(const AiChatInitial()) {
    _subscription = _watchAiMessages(gameId).listen(
      (messages) {
        emit(AiChatReady(messages: messages, sending: _sending));
      },
      onError: (_) {
        emit(
          AiChatReady(
            messages: const [],
            sending: false,
            error: 'No se pudo cargar el chat.',
          ),
        );
      },
    );
  }

  final String gameId;
  final String gameName;
  final SendAiMessage _sendAiMessage;
  final WatchAiMessages _watchAiMessages;
  StreamSubscription<List<ChatMessage>>? _subscription;
  var _sending = false;

  bool get isAvailable => _sendAiMessage.isAvailable;

  Future<void> send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || _sending) {
      return;
    }

    _sending = true;
    final current = state;
    final optimistic = [
      if (current is AiChatReady) ...current.messages,
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
      );
    } catch (error) {
      _sending = false;
      emit(
        AiChatReady(
          messages: optimistic,
          sending: false,
          error: error.toString(),
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
