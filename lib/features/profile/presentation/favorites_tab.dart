import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/game_card.dart';
import '../../../core/widgets/game_grid.dart';
import '../../games/domain/models/game.dart';
import '../../games/presentation/game_details/game_details_page.dart';
import '../../library/domain/models/library_game.dart';
import '../../library/domain/models/library_status.dart';
import '../../library/presentation/cubit/library_cubit.dart';
import '../../library/presentation/cubit/library_state.dart';

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  static const _layoutKey = 'favorites_layout';

  var _layout = LibraryLayout.grid;

  @override
  void initState() {
    super.initState();
    _layout = _readLayout();
  }

  LibraryLayout _readLayout() {
    try {
      final raw = Hive.box<dynamic>('game_cache').get(_layoutKey);
      return raw == LibraryLayout.list.name
          ? LibraryLayout.list
          : LibraryLayout.grid;
    } catch (_) {
      return LibraryLayout.grid;
    }
  }

  Future<void> _toggleLayout() async {
    setState(() {
      _layout = _layout == LibraryLayout.grid
          ? LibraryLayout.list
          : LibraryLayout.grid;
    });
    try {
      if (!Hive.isBoxOpen('game_cache')) {
        return;
      }
      await Hive.box<dynamic>('game_cache').put(_layoutKey, _layout.name);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, state) {
        final favorites = state.favoriteGames;
        if (favorites.isEmpty) {
          return EmptyState(
            icon: Icons.emoji_events_outlined,
            title: 'Aún no hay favoritos',
            message:
                'Completa un juego y márcalo con el corazón para llenar esta pestaña.',
            actionLabel: 'Ir a buscar',
            onAction: () => context.go('/search'),
          );
        }

        final queue = <Game>[for (final item in favorites) item.game];
        final isList = _layout == LibraryLayout.list;
        return CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: _SectionTitle(
                  title: 'Tus 3 más favoritos',
                  subtitle:
                      'Arrastra un juego aquí o toca un puesto para cambiarlo.',
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                child: _PodiumRow(state: state),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 8, 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: _SectionTitle(
                        title: 'Todos tus favoritos',
                        subtitle:
                            'Arrastra para ordenar. Los 3 primeros son el podio.',
                      ),
                    ),
                    IconButton(
                      tooltip: isList ? 'Ver portadas' : 'Ver lista',
                      onPressed: _toggleLayout,
                      icon: Icon(
                        isList
                            ? Icons.grid_view_rounded
                            : Icons.view_list_rounded,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isList)
              SliverReorderableList(
                itemCount: favorites.length,
                onReorderItem: (oldIndex, newIndex) {
                  _reorderFavorites(context, favorites, oldIndex, newIndex);
                },
                proxyDecorator: (child, _, animation) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, _) {
                      return Material(
                        color: AppColors.surface,
                        elevation: 8 * animation.value,
                        borderRadius: BorderRadius.circular(12),
                        child: child,
                      );
                    },
                  );
                },
                itemBuilder: (context, index) {
                  final item = favorites[index];
                  final heroTag = 'favorite-${item.game.id}';
                  return ReorderableDelayedDragStartListener(
                    key: ValueKey(item.game.id),
                    index: index,
                    child: _FavoriteListTile(
                      item: item,
                      heroTag: heroTag,
                      index: index,
                      onOpen: () => openGameDetails(
                        context,
                        item.game,
                        heroTag: heroTag,
                        queue: queue,
                      ),
                    ),
                  );
                },
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
                sliver: SliverGrid(
                  gridDelegate: GameGrid.delegate,
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = favorites[index];
                    final heroTag = 'favorite-${item.game.id}';
                    return _FavoriteTile(
                      item: item,
                      heroTag: heroTag,
                      index: index,
                      favorites: favorites,
                      onOpen: () => openGameDetails(
                        context,
                        item.game,
                        heroTag: heroTag,
                        queue: queue,
                      ),
                    );
                  }, childCount: favorites.length),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.accent,
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceMuted),
        ),
      ],
    );
  }
}

class _PodiumRow extends StatelessWidget {
  const _PodiumRow({required this.state});

  final LibraryState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _PodiumSlot(
            rank: 2,
            item: state.favoriteAtRank(2),
            height: 168,
            label: '2.º',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: _PodiumSlot(
            rank: 1,
            item: state.favoriteAtRank(1),
            height: 214,
            label: '1.º',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PodiumSlot(
            rank: 3,
            item: state.favoriteAtRank(3),
            height: 168,
            label: '3.º',
          ),
        ),
      ],
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  const _PodiumSlot({
    required this.rank,
    required this.item,
    required this.height,
    required this.label,
  });

  final int rank;
  final LibraryGame? item;
  final double height;
  final String label;

  @override
  Widget build(BuildContext context) {
    final game = item?.game;
    return Column(
      children: [
        DragTarget<String>(
          onWillAcceptWithDetails: (details) => details.data != game?.id,
          onAcceptWithDetails: (details) {
            _assignRank(context, gameId: details.data, rank: rank);
          },
          builder: (context, candidate, _) {
            final highlighted = candidate.isNotEmpty;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (game == null) {
                    _openRankPicker(context, rank);
                    return;
                  }
                  _openSlotActions(context, rank: rank, item: item!);
                },
                borderRadius: BorderRadius.circular(16),
                child: Ink(
                  height: height,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: highlighted
                          ? AppColors.accent
                          : rank == 1
                          ? AppColors.accent.withValues(alpha: 0.7)
                          : AppColors.outline,
                      width: highlighted ? 2 : 1,
                    ),
                  ),
                  child: game == null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                color: AppColors.accent,
                                size: rank == 1 ? 32 : 26,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Elegir',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(color: AppColors.onSurfaceMuted),
                              ),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                imageUrl: game.coverUrl ?? '',
                                fit: BoxFit.cover,
                                errorWidget: (_, _, _) => ColoredBox(
                                  color: AppColors.surfaceHigh,
                                ),
                              ),
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0x00000000),
                                      Color(0xD107080B),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 8,
                                right: 8,
                                bottom: 10,
                                child: Text(
                                  game.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: rank == 1 ? AppColors.accent : AppColors.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _FavoriteListTile extends StatelessWidget {
  const _FavoriteListTile({
    required this.item,
    required this.heroTag,
    required this.index,
    required this.onOpen,
  });

  final LibraryGame item;
  final String heroTag;
  final int index;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final rank = item.entry.favoriteRank;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outline)),
      ),
      child: Stack(
        children: [
          GameListRow(game: item.game, heroTag: heroTag, onTap: onOpen),
          if (rank != null)
            Positioned(top: 10, left: 12, child: _RankBadge(rank: rank)),
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: ReorderableDragStartListener(
              index: index,
              child: Icon(
                Icons.drag_handle_rounded,
                color: AppColors.onSurfaceMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({
    required this.item,
    required this.heroTag,
    required this.index,
    required this.favorites,
    required this.onOpen,
  });

  final LibraryGame item;
  final String heroTag;
  final int index;
  final List<LibraryGame> favorites;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final rank = item.entry.favoriteRank;
    final tile = Stack(
      children: [
        GameGridCard(game: item.game, heroTag: heroTag, onTap: onOpen),
        if (rank != null)
          Positioned(top: 8, left: 8, child: _RankBadge(rank: rank)),
      ],
    );

    return LongPressDraggable<String>(
      data: item.game.id,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: _DragCover(url: item.game.coverUrl, name: item.game.name),
      childWhenDragging: Opacity(opacity: 0.35, child: tile),
      child: DragTarget<String>(
        onWillAcceptWithDetails: (details) => details.data != item.game.id,
        onAcceptWithDetails: (details) {
          _moveFavoriteTo(context, favorites, details.data, index);
        },
        builder: (context, candidate, _) {
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: candidate.isEmpty
                  ? null
                  : Border.all(color: AppColors.accent, width: 2),
            ),
            child: tile,
          );
        },
      ),
    );
  }
}

class _DragCover extends StatelessWidget {
  const _DragCover({required this.url, required this.name});

  final String? url;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 10,
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 86,
          height: 116,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: url ?? '',
                fit: BoxFit.cover,
                errorWidget: (_, _, _) =>
                    ColoredBox(color: AppColors.surfaceHigh),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xC107080B)],
                  ),
                ),
              ),
              Positioned(
                left: 6,
                right: 6,
                bottom: 6,
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          '#$rank',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.background,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

Future<void> _openSlotActions(
  BuildContext context, {
  required int rank,
  required LibraryGame item,
}) async {
  final action = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.game.name,
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.swap_horiz_rounded),
                title: const Text('Cambiar este puesto'),
                onTap: () => Navigator.pop(sheetContext, 'change'),
              ),
              ListTile(
                leading: const Icon(Icons.visibility_rounded),
                title: const Text('Ver ficha'),
                onTap: () => Navigator.pop(sheetContext, 'open'),
              ),
              ListTile(
                leading: const Icon(Icons.remove_circle_outline_rounded),
                title: const Text('Quitar del podio'),
                onTap: () => Navigator.pop(sheetContext, 'clear'),
              ),
            ],
          ),
        ),
      );
    },
  );

  if (!context.mounted || action == null) {
    return;
  }
  if (action == 'change') {
    await _openRankPicker(context, rank);
    return;
  }
  if (action == 'open') {
    openGameDetails(context, item.game, heroTag: 'favorite-${item.game.id}');
    return;
  }
  if (action == 'clear') {
    await _assignRank(context, gameId: item.game.id, rank: null);
  }
}

Future<void> _openRankPicker(BuildContext context, int rank) async {
  final favorites = context.read<LibraryCubit>().state.favoriteGames;
  final selected = await showModalBottomSheet<LibraryGame>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.62,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              Text(
                'Elegir el $rank.º favorito',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: favorites.length,
                  separatorBuilder: (_, _) =>
                      Divider(color: AppColors.outline),
                  itemBuilder: (context, index) {
                    final item = favorites[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 40,
                          height: 54,
                          child: CachedNetworkImage(
                            imageUrl: item.game.coverUrl ?? '',
                            fit: BoxFit.cover,
                            errorWidget: (_, _, _) =>
                                ColoredBox(color: AppColors.surfaceHigh),
                          ),
                        ),
                      ),
                      title: Text(item.game.name),
                      subtitle: item.entry.favoriteRank == null
                          ? null
                          : Text('Ahora es #${item.entry.favoriteRank}'),
                      onTap: () => Navigator.pop(sheetContext, item),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  if (!context.mounted || selected == null) {
    return;
  }
  await _assignRank(context, gameId: selected.game.id, rank: rank);
}

void _reorderFavorites(
  BuildContext context,
  List<LibraryGame> favorites,
  int oldIndex,
  int newIndex,
) {
  final ids = [for (final item in favorites) item.game.id];
  final moved = ids.removeAt(oldIndex);
  ids.insert(newIndex.clamp(0, ids.length), moved);
  context.read<LibraryCubit>().reorderFavorites(ids);
}

void _moveFavoriteTo(
  BuildContext context,
  List<LibraryGame> favorites,
  String gameId,
  int toIndex,
) {
  final ids = [for (final item in favorites) item.game.id];
  final from = ids.indexOf(gameId);
  if (from < 0 || from == toIndex) {
    return;
  }
  ids.removeAt(from);
  final dest = from < toIndex ? toIndex - 1 : toIndex;
  ids.insert(dest.clamp(0, ids.length), gameId);
  context.read<LibraryCubit>().reorderFavorites(ids);
}

Future<void> _assignRank(
  BuildContext context, {
  required String gameId,
  int? rank,
}) async {
  try {
    await context.read<LibraryCubit>().setFavoriteRank(
      gameId: gameId,
      rank: rank,
    );
  } catch (_) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No se pudo actualizar el podio.')),
    );
  }
}
