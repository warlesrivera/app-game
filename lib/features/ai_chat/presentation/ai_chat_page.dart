import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/theme/app_colors.dart';
import '../domain/models/chat_message.dart';
import 'cubit/ai_chat_cubit.dart';
import 'cubit/ai_chat_state.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({
    super.key,
    required this.gameName,
  });

  final String gameName;

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.gameName),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<AiChatCubit, AiChatState>(
              listener: (context, state) {
                if (state is AiChatReady) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scroll.hasClients) {
                      _scroll.jumpTo(_scroll.position.maxScrollExtent);
                    }
                  });
                }
              },
              builder: (context, state) {
                final ready = state is AiChatReady ? state : null;
                final messages = ready?.messages ?? const <ChatMessage>[];
                if (messages.isEmpty && ready?.sending != true) {
                  return Center(
                    child: Text(
                      'Pregunta lo que quieras sobre ${widget.gameName}.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  itemCount: messages.length + (ready?.sending == true ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= messages.length) {
                      return const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: _Bubble(
                            text: 'Pensando…',
                            isUser: false,
                          ),
                        ),
                      );
                    }
                    final message = messages[index];
                    return _Bubble(
                      text: message.text,
                      isUser: message.isUser,
                    );
                  },
                );
              },
            ),
          ),
          BlocBuilder<AiChatCubit, AiChatState>(
            builder: (context, state) {
              final error = state is AiChatReady ? state.error : null;
              if (error == null) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  error,
                  style: const TextStyle(color: AppColors.error),
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Escribe tu pregunta',
                      ),
                      onSubmitted: _send,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () => _send(_controller.text),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _send(String value) {
    context.read<AiChatCubit>().send(value);
    _controller.clear();
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.text,
    required this.isUser,
  });

  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isUser ? AppColors.accent : AppColors.surfaceHigh,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isUser ? AppColors.background : AppColors.onSurface,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
