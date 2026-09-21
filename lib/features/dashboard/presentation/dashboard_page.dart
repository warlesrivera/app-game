import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/catalog_games_row.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../auth/presentation/cubit/auth_state.dart';
import 'cubit/dashboard_cubit.dart';
import 'cubit/dashboard_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const _skeletonTitles = [
    'DESCUBRE',
    'PLAYSTATION',
    'NINTENDO',
    'XBOX',
    'ÚLTIMA GENERACIÓN',
    'RETROS',
  ];

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
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              sliver: SliverToBoxAdapter(
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
            ),
            BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                return switch (state) {
                  DashboardLoaded(:final rows) => SliverList.separated(
                    itemCount: rows.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final row = rows[index];
                      return CatalogGamesRow(
                        title: row.title,
                        games: row.games,
                        heroPrefix: row.id,
                      );
                    },
                  ),
                  DashboardError(:final message) => SliverToBoxAdapter(
                    child: _DiscoverError(message: message),
                  ),
                  _ => SliverList.separated(
                    itemCount: _skeletonTitles.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return CatalogGamesRowSkeleton(
                        title: _skeletonTitles[index],
                      );
                    },
                  ),
                };
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
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
