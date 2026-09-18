import 'package:equatable/equatable.dart';

import '../../domain/models/chat_message.dart';

sealed class AiChatState extends Equatable {
  const AiChatState();

  @override
  List<Object?> get props => [];
}

final class AiChatInitial extends AiChatState {
  const AiChatInitial();
}

final class AiChatReady extends AiChatState {
  const AiChatReady({
    required this.messages,
    this.sending = false,
    this.error,
  });

  final List<ChatMessage> messages;
  final bool sending;
  final String? error;

  @override
  List<Object?> get props => [messages, sending, error];
}
