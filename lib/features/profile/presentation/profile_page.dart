import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/theme/app_colors.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../auth/presentation/cubit/auth_state.dart';
import '../../library/presentation/cubit/library_cubit.dart';
import '../../library/presentation/cubit/library_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            Text(
              'PERFIL',
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.accent,
                letterSpacing: 2.2,
              ),
            ),
            const SizedBox(height: 24),
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                final user = state is AuthAuthenticated ? state.user : null;
                final name = user?.name.trim().isNotEmpty == true
                    ? user!.name
                    : 'Gamer';
                final email = user?.email ?? '';
                final initial = name.isNotEmpty ? name[0].toUpperCase() : 'G';

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.surfaceHigh,
                      child: Text(
                        initial,
                        style: textTheme.headlineMedium?.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: textTheme.titleLarge),
                          const SizedBox(height: 4),
                          Text(email, style: textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            BlocBuilder<LibraryCubit, LibraryState>(
              builder: (context, state) {
                final stats = state.stats;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _StatCard(label: 'Completados', value: stats.completed),
                    _StatCard(label: 'En Wishlist', value: stats.wishlist),
                    _StatCard(label: 'Jugando', value: stats.playing),
                    _StatCard(label: 'Abandonados', value: stats.abandoned),
                  ],
                );
              },
            ),
            const SizedBox(height: 36),
            OutlinedButton.icon(
              onPressed: () => context.read<AuthCubit>().signOut(),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 6),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
