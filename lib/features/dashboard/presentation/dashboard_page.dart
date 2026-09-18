import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/game_card.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../auth/presentation/cubit/auth_state.dart';
import '../../games/domain/models/game.dart';
import '../../games/presentation/game_details/game_details_page.dart';
import 'cubit/dashboard_cubit.dart';
import 'cubit/dashboard_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final name = _displayName(state);
                    return Text(
                      'Hola, $name',
                      style: textTheme.headlineMedium,
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'DESCUBRE',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.accent,
                    letterSpacing: 2.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, state) {
                  return switch (state) {
                    DashboardLoaded(:final games) => _DiscoverRow(games: games),
                    DashboardError(:final message) => _DiscoverError(
                      message: message,
                    ),
                    _ => const _DiscoverSkeleton(),
                  };
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _displayName(AuthState state) {
    if (state is AuthAuthenticated) {
      final name = state.user.name.trim();
      if (name.isNotEmpty) {
        return name;
      }
      final email = state.user.email.trim();
      if (email.contains('@')) {
        return email.split('@').first;
      }
    }
    return 'gamer';
  }
}

class _DiscoverRow extends StatefulWidget {
  const _DiscoverRow({required this.games});

  final List<Game> games;

  @override
  State<_DiscoverRow> createState() => _DiscoverRowState();
}

class _DiscoverRowState extends State<_DiscoverRow> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_controller.hasClients) {
      return;
    }

    final next = (_controller.offset + event.scrollDelta.dy + event.scrollDelta.dx)
        .clamp(0.0, _controller.position.maxScrollExtent);
    _controller.jumpTo(next);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.games.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Text('No hay juegos para descubrir ahora mismo.'),
      );
    }

    return SizedBox(
      height: GameCard.height,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: true,
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
            PointerDeviceKind.stylus,
          },
        ),
        child: Listener(
          onPointerSignal: _onPointerSignal,
          child: ListView.separated(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: widget.games.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final game = widget.games[index];
              final heroTag = 'discover-${game.id}';
              return GameCard(
                game: game,
                heroTag: heroTag,
                onTap: () => openGameDetails(
                  context,
                  game,
                  heroTag: heroTag,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DiscoverSkeleton extends StatelessWidget {
  const _DiscoverSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: GameCard.height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: 6,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, _) => const GameCardSkeleton(),
      ),
    );
  }
}

class _DiscoverError extends StatelessWidget {
  const _DiscoverError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              context.read<DashboardCubit>().loadDiscoverGames();
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
