import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/game_card.dart';
import '../../../../core/widgets/game_grid.dart';
import '../../../games/domain/models/catalog_collection.dart';
import '../../../games/domain/models/game.dart';
import '../../../games/presentation/game_details/game_details_page.dart';
import '../../../library/domain/models/library_status.dart';
import 'catalog_collection_cubit.dart';
import 'catalog_collection_state.dart';

void openCatalogCollection(
  BuildContext context, {
  required String id,
  required String title,
}) {
  context.pushNamed(
    'catalogCollection',
    pathParameters: {'id': id},
    extra: title,
  );
}

class CatalogCollectionPage extends StatelessWidget {
  const CatalogCollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: BlocBuilder<CatalogCollectionCubit, CatalogCollectionState>(
          buildWhen: (previous, current) => previous.title != current.title,
          builder: (context, state) {
            return Text(
              state.title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.accent,
                letterSpacing: 2.2,
              ),
            );
          },
        ),
        actions: [
          BlocBuilder<CatalogCollectionCubit, CatalogCollectionState>(
            buildWhen: (previous, current) => previous.layout != current.layout,
            builder: (context, state) {
              final isList = state.layout == LibraryLayout.list;
              return IconButton(
                tooltip: isList ? 'Ver en cuadrícula' : 'Ver en lista',
                onPressed: () =>
                    context.read<CatalogCollectionCubit>().toggleLayout(),
                icon: Icon(
                  isList ? Icons.grid_view_rounded : Icons.view_list_rounded,
                  color: AppColors.onSurface,
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CatalogCollectionCubit, CatalogCollectionState>(
        builder: (context, state) {
          if (state.loading && state.sections.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          if (state.error != null && state.sections.isEmpty) {
            return EmptyState(
              icon: Icons.videogame_asset_off_rounded,
              title: 'No se pudo cargar',
              message: state.error!,
              actionLabel: 'Reintentar',
              onAction: () => context.read<CatalogCollectionCubit>().load(),
            );
          }

          if (state.sections.isEmpty) {
            return const EmptyState(
              icon: Icons.sports_esports_outlined,
              title: 'Sin juegos',
              message: 'Esta lista no tiene resultados ahora.',
            );
          }

          final selected = state.selected;
          return Column(
            children: [
              _ConsoleChips(
                sections: state.sections,
                selectedId: selected?.id,
                onSelected: (id) =>
                    context.read<CatalogCollectionCubit>().selectSection(id),
              ),
              Expanded(
                child: selected == null
                    ? const SizedBox.shrink()
                    : _SectionBody(section: selected, layout: state.layout),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ConsoleChips extends StatelessWidget {
  const _ConsoleChips({
    required this.sections,
    required this.selectedId,
    required this.onSelected,
  });

  final List<CatalogSection> sections;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        itemCount: sections.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final section = sections[index];
          final selected = section.id == selectedId;
          return ChoiceChip(
            label: Text(section.title),
            selected: selected,
            onSelected: (_) => onSelected(section.id),
            selectedColor: AppColors.accent.withValues(alpha: 0.28),
            backgroundColor: AppColors.surfaceHigh,
            showCheckmark: false,
            side: BorderSide(
              color: selected ? AppColors.accent : AppColors.outline,
            ),
            labelStyle: TextStyle(
              color: selected ? AppColors.onSurface : AppColors.onSurfaceMuted,
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
    );
  }
}

class _SectionBody extends StatelessWidget {
  const _SectionBody({
    required this.section,
    required this.layout,
  });

  final CatalogSection section;
  final LibraryLayout layout;

  @override
  Widget build(BuildContext context) {
    if (section.loading && section.games.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (section.games.isEmpty) {
      return EmptyState(
        icon: Icons.sports_esports_outlined,
        title: 'Sin juegos',
        message: 'No hay resultados para ${section.title}.',
        actionLabel: 'Reintentar',
        onAction: () =>
            context.read<CatalogCollectionCubit>().ensureSection(section.id),
      );
    }

    return layout == LibraryLayout.list
        ? _GamesList(section: section)
        : _GamesGrid(section: section);
  }
}

class _GamesGrid extends StatelessWidget {
  const _GamesGrid({required this.section});

  final CatalogSection section;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          sliver: SliverGrid(
            gridDelegate: GameGrid.delegate,
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final game = section.games[index];
                return _gameTile(
                  context,
                  game: game,
                  section: section,
                  grid: true,
                );
              },
              childCount: section.games.length,
            ),
          ),
        ),
        SliverToBoxAdapter(child: _MoreButton(section: section)),
      ],
    );
  }
}

class _GamesList extends StatelessWidget {
  const _GamesList({required this.section});

  final CatalogSection section;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: section.games.length + 1,
      separatorBuilder: (context, index) {
        if (index >= section.games.length - 1) {
          return const SizedBox.shrink();
        }
        return Divider(
          height: 1,
          color: AppColors.outline,
          indent: 94,
        );
      },
      itemBuilder: (context, index) {
        if (index == section.games.length) {
          return _MoreButton(section: section);
        }
        final game = section.games[index];
        return _gameTile(
          context,
          game: game,
          section: section,
          grid: false,
        );
      },
    );
  }
}

class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.section});

  final CatalogSection section;

  @override
  Widget build(BuildContext context) {
    if (!section.hasMore && !section.loadingMore) {
      return const SizedBox(height: 24);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      child: Center(
        child: section.loadingMore
            ? SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: AppColors.accent,
                ),
              )
            : OutlinedButton.icon(
                onPressed: () =>
                    context.read<CatalogCollectionCubit>().loadMore(section.id),
                icon: const Icon(Icons.add_rounded),
                label: Text('Ver más de ${section.title}'),
              ),
      ),
    );
  }
}

Widget _gameTile(
  BuildContext context, {
  required Game game,
  required CatalogSection section,
  required bool grid,
}) {
  final heroTag = '${section.id}-${game.id}';
  void open() {
    openGameDetails(
      context,
      game,
      heroTag: heroTag,
      queue: section.games,
    );
  }

  if (grid) {
    return GameGridCard(
      game: game,
      heroTag: heroTag,
      onTap: open,
    );
  }

  return GameListRow(
    game: game,
    heroTag: heroTag,
    onTap: open,
  );
}
