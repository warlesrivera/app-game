import 'package:equatable/equatable.dart';

enum ChatRole { user, assistant }

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    this.createdAt,
  });

  final String id;
  final ChatRole role;
  final String text;
  final DateTime? createdAt;

  bool get isUser => role == ChatRole.user;

  @override
  List<Object?> get props => [id, role, text, createdAt];
}
