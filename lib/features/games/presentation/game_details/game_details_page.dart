import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/platform_icon_mapper.dart';
import '../../../library/domain/models/library_entry.dart';
import '../../../library/domain/models/library_status.dart';
import '../../../library/presentation/cubit/library_cubit.dart';
import '../../../library/presentation/cubit/library_state.dart';
import '../../domain/models/game.dart';

class GameDetailsArgs {
  const GameDetailsArgs({
    required this.game,
    required this.heroTag,
  });

  final Game game;
  final String heroTag;

  static GameDetailsArgs? tryParse(Object? extra) {
    if (extra is GameDetailsArgs) {
      return extra;
    }
    if (extra is Game) {
      return GameDetailsArgs(
        game: extra,
        heroTag: 'game-cover-${extra.id}',
      );
    }
    return null;
  }
}

void openGameDetails(
  BuildContext context,
  Game game, {
  required String heroTag,
}) {
  context.pushNamed(
    'gameDetails',
    pathParameters: {'id': game.id},
    extra: GameDetailsArgs(game: game, heroTag: heroTag),
  );
}

class GameDetailsPage extends StatelessWidget {
  const GameDetailsPage({
    super.key,
    required this.game,
    required this.heroTag,
  });

  final Game game;
  final String heroTag;

  factory GameDetailsPage.fromRoute({
    required String id,
    Object? extra,
  }) {
    final args = GameDetailsArgs.tryParse(extra);
    return GameDetailsPage(
      game: args?.game ?? Game(id: id, name: 'Juego'),
      heroTag: args?.heroTag ?? 'game-cover-$id',
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _HeroHeader(game: game, heroTag: heroTag),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.name,
                    style: textTheme.displaySmall?.copyWith(
                      letterSpacing: -0.8,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _StatusActions(gameId: game.id),
                  const SizedBox(height: 16),
                  _PriceAlertButton(game: game),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      context.pushNamed(
                        'aiChat',
                        pathParameters: {'id': game.id},
                        extra: game,
                      );
                    },
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Pregúntale a la IA'),
                  ),
                  const SizedBox(height: 24),
                  _PlatformRow(platforms: game.platforms),
                  const SizedBox(height: 20),
                  _MetaRow(game: game),
                  if (_hasDescription) ...[
                    const SizedBox(height: 28),
                    Text(
                      'SINOPSIS',
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.accent,
                        letterSpacing: 2.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      game.description!.trim(),
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurface,
                        height: 1.55,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasDescription {
    final description = game.description?.trim();
    return description != null && description.isNotEmpty;
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.game,
    required this.heroTag,
  });

  final Game game;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: heroTag,
            child: Material(
              color: AppColors.surfaceHigh,
              child: _CoverImage(url: game.coverUrl),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x6607080B),
                  Color(0x0007080B),
                  Color(0xF207080B),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                tooltip: 'Volver',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const ColoredBox(color: AppColors.surfaceHigh);
    }

    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      fadeInDuration: Duration.zero,
      placeholder: (context, _) {
        return const ColoredBox(color: AppColors.surfaceHigh);
      },
      errorWidget: (context, _, _) {
        return const ColoredBox(color: AppColors.surface);
      },
    );
  }
}

class _StatusActions extends StatelessWidget {
  const _StatusActions({required this.gameId});

  final String gameId;

  static const _actions = [
    (status: LibraryStatus.completed, icon: Icons.check_circle_outline),
    (status: LibraryStatus.playing, icon: Icons.sports_esports_outlined),
    (status: LibraryStatus.wishlist, icon: Icons.favorite_outline_rounded),
    (status: LibraryStatus.abandoned, icon: Icons.heart_broken_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, state) {
        final selected = state.entryFor(gameId)?.status;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final action in _actions)
              ChoiceChip(
                label: Text(action.status.label),
                avatar: Icon(action.icon, size: 16),
                selected: selected == action.status,
                onSelected: (_) {
                  context.read<LibraryCubit>().setStatus(
                    gameId: gameId,
                    status: action.status,
                  );
                },
                selectedColor: AppColors.accent.withValues(alpha: 0.28),
                backgroundColor: AppColors.surfaceHigh,
                labelStyle: TextStyle(
                  color: selected == action.status
                      ? AppColors.onSurface
                      : AppColors.onSurfaceMuted,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                  color: selected == action.status
                      ? AppColors.accent
                      : AppColors.outline,
                ),
                showCheckmark: false,
              ),
          ],
        );
      },
    );
  }
}

class _PriceAlertButton extends StatelessWidget {
  const _PriceAlertButton({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, state) {
        final entry = state.entryFor(game.id);
        if (entry == null || entry.status != LibraryStatus.wishlist) {
          return const SizedBox.shrink();
        }

        return OutlinedButton.icon(
          onPressed: () => _openSheet(context, entry),
          icon: Icon(
            entry.priceAlerts
                ? Icons.notifications_active_rounded
                : Icons.notifications_outlined,
          ),
          label: Text(
            entry.priceAlerts ? 'Alerta de precio activa' : 'Alerta de precio',
          ),
        );
      },
    );
  }

  Future<void> _openSheet(BuildContext context, LibraryEntry entry) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return _PriceAlertSheet(
          gameId: game.id,
          initialStores: entry.targetStores,
          initiallyEnabled: entry.priceAlerts,
        );
      },
    );
  }
}

class _PriceAlertSheet extends StatefulWidget {
  const _PriceAlertSheet({
    required this.gameId,
    required this.initialStores,
    required this.initiallyEnabled,
  });

  final String gameId;
  final List<String> initialStores;
  final bool initiallyEnabled;

  @override
  State<_PriceAlertSheet> createState() => _PriceAlertSheetState();
}

class _PriceAlertSheetState extends State<_PriceAlertSheet> {
  static const _stores = ['Steam', 'PlayStation', 'Xbox', 'Epic'];

  late final Set<String> _selected = {...widget.initialStores};

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Alerta de precio',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Elige las tiendas. El escaneo lo hará una Cloud Function, no el teléfono.',
          ),
          const SizedBox(height: 16),
          for (final store in _stores)
            CheckboxListTile(
              value: _selected.contains(store),
              onChanged: (checked) {
                setState(() {
                  if (checked ?? false) {
                    _selected.add(store);
                  } else {
                    _selected.remove(store);
                  }
                });
              },
              title: Text(store),
              activeColor: AppColors.accent,
              contentPadding: EdgeInsets.zero,
            ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () async {
              await context.read<LibraryCubit>().savePriceAlert(
                gameId: widget.gameId,
                enabled: _selected.isNotEmpty,
                stores: _selected.toList(),
              );
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Guardar alerta'),
          ),
        ],
      ),
    );
  }
}

class _PlatformRow extends StatelessWidget {
  const _PlatformRow({required this.platforms});

  final List<String> platforms;

  @override
  Widget build(BuildContext context) {
    final icons = PlatformIconMapper.uniqueIcons(platforms);
    if (icons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        for (final item in icons)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Tooltip(
              message: item.label,
              child: Icon(
                item.icon,
                color: AppColors.onSurface,
                size: 22,
              ),
            ),
          ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final items = <Widget>[
      if (game.releaseDate != null)
        _MetaChip(
          icon: Icons.event_outlined,
          label: _formatDate(game.releaseDate!),
        ),
      if (game.rating != null && game.rating! > 0)
        _MetaChip(
          icon: Icons.star_rounded,
          label: game.rating!.toStringAsFixed(1),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (items.isNotEmpty)
          Wrap(spacing: 8, runSpacing: 8, children: items),
        if (game.genres.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(game.genres.join('  ·  '), style: textTheme.bodyMedium),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.accent),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
