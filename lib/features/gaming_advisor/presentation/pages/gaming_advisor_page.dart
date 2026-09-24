import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../library/domain/models/library_status.dart';
import '../../../library/presentation/cubit/library_cubit.dart';
import '../cubit/gaming_advisor_cubit.dart';
import '../cubit/gaming_advisor_state.dart';
import '../../domain/models/gaming_models.dart';

class AdvisorLaunch {
  const AdvisorLaunch({this.question, this.focusGameId});

  final String? question;
  final String? focusGameId;
}

class GamingAdvisorPage extends StatefulWidget {
  const GamingAdvisorPage({super.key, this.launch});

  final AdvisorLaunch? launch;

  @override
  State<GamingAdvisorPage> createState() => _GamingAdvisorPageState();
}

class _GamingAdvisorPageState extends State<GamingAdvisorPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  static const _suggestions = [
    '¿Qué debería jugar después?',
    '¿Qué juego me puede gustar?',
    '¿Qué tengo pendiente?',
    '¿Qué debería comprar?',
    '¿Qué juego puedo jugar este fin de semana?',
    'Compara estos dos juegos para mí.',
  ];

  @override
  void initState() {
    super.initState();
    final launch = widget.launch;
    if (launch?.question != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        context.read<GamingAdvisorCubit>().askQuestion(
          launch!.question!,
          focusGameId: launch.focusGameId,
        );
      });
    }
  }

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
        backgroundColor: AppColors.background,
        title: const Text('Tu Gaming Advisor'),
        actions: [
          IconButton(
            tooltip: 'Perfil de jugador',
            onPressed: () => context.pushNamed('gamingProfile'),
            icon: const Icon(Icons.tune_rounded),
          ),
          IconButton(
            tooltip: 'Memoria',
            onPressed: () => context.pushNamed('gamingMemory'),
            icon: const Icon(Icons.psychology_alt_outlined),
          ),
          IconButton(
            tooltip: 'Mi aventura',
            onPressed: () => context.pushNamed('gamingTimeline'),
            icon: const Icon(Icons.timeline_rounded),
          ),
          IconButton(
            tooltip: 'Limpiar chat',
            onPressed: () => context.read<GamingAdvisorCubit>().clearConversation(),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<GamingAdvisorCubit, GamingAdvisorState>(
              listenWhen: (previous, current) =>
                  previous.messages.length != current.messages.length,
              listener: (_, _) {
                if (!_scroll.hasClients) {
                  return;
                }
                _scroll.animateTo(
                  _scroll.position.maxScrollExtent + 80,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                );
              },
              builder: (context, state) {
                if (state.status == AdvisorStatus.loading && state.messages.isEmpty) {
                  return const Center(child: Text('Analizando tus gustos...'));
                }
                return ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    Text(
                      'Tu biblioteca. Tus gustos. Tu próxima aventura.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final suggestion in _suggestions)
                          ActionChip(
                            label: Text(suggestion),
                            onPressed: () => context
                                .read<GamingAdvisorCubit>()
                                .askQuestion(suggestion),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    for (final message in state.messages) _Bubble(message: message),
                    if (state.notice != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          state.notice!,
                          style: TextStyle(color: AppColors.accent),
                        ),
                      ),
                    if (state.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          state.error!,
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Pregúntame sobre tus juegos...',
                      ),
                      onSubmitted: _send,
                    ),
                  ),
                  IconButton(
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
    final text = value.trim();
    if (text.isEmpty) {
      return;
    }
    _controller.clear();
    context.read<GamingAdvisorCubit>().askQuestion(
      text,
      focusGameId: widget.launch?.focusGameId,
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final AdvisorMessage message;

  @override
  Widget build(BuildContext context) {
    final mine = message.isUser;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          color: mine ? AppColors.accent.withValues(alpha: 0.2) : AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.text),
            for (final card in message.cards) _RecommendationCard(card: card),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.card});

  final AdvisorRecommendation card;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (card.coverUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(
                    imageUrl: card.coverUrl!,
                    width: 42,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(card.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    if (card.status != null)
                      Text(card.status!, style: TextStyle(color: AppColors.onSurfaceMuted)),
                    if (card.releaseLabel != null) Text(card.releaseLabel!),
                  ],
                ),
              ),
            ],
          ),
          if (card.reasons.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('¿Por qué?'),
            for (final reason in card.reasons) Text('✓ $reason'),
          ],
          if (card.warning != null) ...[
            const SizedBox(height: 6),
            Text('⚠ ${card.warning}'),
          ],
          Wrap(
            spacing: 6,
            children: [
              TextButton(
                onPressed: () => context.push('/game/${card.gameId}'),
                child: const Text('Ver detalles'),
              ),
              TextButton(
                onPressed: () => context.read<LibraryCubit>().setStatus(
                  gameId: card.gameId,
                  status: LibraryStatus.wishlist,
                ),
                child: const Text('Wishlist'),
              ),
              TextButton(
                onPressed: () {
                  context.read<LibraryCubit>().setStatus(
                    gameId: card.gameId,
                    status: LibraryStatus.playing,
                  );
                  context.read<GamingAdvisorCubit>().setCurrentGame(card.gameId);
                },
                child: const Text('Jugando'),
              ),
              TextButton(
                onPressed: () => context.read<GamingAdvisorCubit>().askQuestion(
                  '¿Por qué me recomiendas ${card.name}?',
                  focusGameId: card.gameId,
                ),
                child: const Text('¿Por qué?'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
