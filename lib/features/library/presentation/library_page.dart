import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/game_card.dart';
import '../../../core/widgets/game_grid.dart';
import '../../games/presentation/game_details/game_details_page.dart';
import '../domain/models/library_status.dart';
import 'cubit/library_cubit.dart';
import 'cubit/library_state.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({
    super.key,
    this.initialFilter = LibraryFilter.all,
    this.title = 'Biblioteca',
  });

  final LibraryFilter initialFilter;
  final String title;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LibraryCubit>();
    if (cubit.state.filter != initialFilter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          cubit.setFilter(initialFilter);
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title.toUpperCase(),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.accent,
                        letterSpacing: 2.2,
                      ),
                    ),
                  ),
                  BlocBuilder<LibraryCubit, LibraryState>(
                    buildWhen: (previous, current) =>
                        previous.layout != current.layout,
                    builder: (context, state) {
                      final isList = state.layout == LibraryLayout.list;
                      return IconButton(
                        tooltip: isList ? 'Ver en cuadrícula' : 'Ver en lista',
                        onPressed: () =>
                            context.read<LibraryCubit>().toggleLayout(),
                        icon: Icon(
                          isList
                              ? Icons.grid_view_rounded
                              : Icons.view_list_rounded,
                          color: AppColors.onSurface,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (title != 'Deseos')
              SizedBox(
                height: 44,
                child: BlocBuilder<LibraryCubit, LibraryState>(
                  builder: (context, state) {
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: LibraryFilter.values.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final filter = LibraryFilter.values[index];
                        final selected = state.filter == filter;
                        return ChoiceChip(
                          label: Text(filter.label),
                          selected: selected,
                          onSelected: (_) {
                            context.read<LibraryCubit>().setFilter(filter);
                          },
                          selectedColor: AppColors.accent.withValues(alpha: 0.28),
                          backgroundColor: AppColors.surfaceHigh,
                          showCheckmark: false,
                          side: BorderSide(
                            color: selected ? AppColors.accent : AppColors.outline,
                          ),
                          labelStyle: TextStyle(
                            color: selected
                                ? AppColors.onSurface
                                : AppColors.onSurfaceMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
            const Expanded(child: _LibraryBody()),
          ],
        ),
      ),
    );
  }
}

class _LibraryBody extends StatelessWidget {
  const _LibraryBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, state) {
        return switch (state) {
          LibraryLoaded() => _LibraryContent(state: state),
          LibraryError(:final message) => EmptyState(
            icon: Icons.wifi_off_rounded,
            title: 'No se pudo cargar',
            message: message,
            actionLabel: 'Reintentar',
            onAction: () => context.read<LibraryCubit>().retry(),
          ),
          _ => _LibrarySkeleton(layout: state.layout),
        };
      },
    );
  }
}

class _LibraryContent extends StatelessWidget {
  const _LibraryContent({required this.state});

  final LibraryLoaded state;

  @override
  Widget build(BuildContext context) {
    final games = state.visibleGames;
    if (games.isEmpty) {
      return EmptyState(
        icon: Icons.sports_esports_rounded,
        title: 'Tu bóveda está vacía',
        message: 'Busca un juego y márcalo como jugando, completado o wishlist.',
        actionLabel: 'Ir a buscar',
        onAction: () => context.go('/search'),
      );
    }

    final queue = [for (final item in games) item.game];
    if (state.layout == LibraryLayout.list) {
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
        itemCount: games.length,
        separatorBuilder: (_, _) => const Divider(
          height: 1,
          color: AppColors.outline,
          indent: 94,
        ),
        itemBuilder: (context, index) {
          final item = games[index];
          final heroTag = 'library-${item.game.id}';
          return GameListRow(
            game: item.game,
            heroTag: heroTag,
            onTap: () => openGameDetails(
              context,
              item.game,
              heroTag: heroTag,
              queue: queue,
            ),
          );
        },
      );
    }

    return GameGrid(
      itemCount: games.length,
      itemBuilder: (context, index) {
        final item = games[index];
        final heroTag = 'library-${item.game.id}';
        return GameGridCard(
          game: item.game,
          heroTag: heroTag,
          onTap: () => openGameDetails(
            context,
            item.game,
            heroTag: heroTag,
            queue: queue,
          ),
        );
      },
    );
  }
}

class _LibrarySkeleton extends StatelessWidget {
  const _LibrarySkeleton({required this.layout});

  final LibraryLayout layout;

  @override
  Widget build(BuildContext context) {
    if (layout == LibraryLayout.list) {
      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        itemBuilder: (_, _) => const Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: SizedBox(
            height: 86,
            child: GameCardSkeleton(fill: true),
          ),
        ),
      );
    }

    return GameGrid(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      itemBuilder: (_, _) => const GameCardSkeleton(fill: true),
    );
  }
}
