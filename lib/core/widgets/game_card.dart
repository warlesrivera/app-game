import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../features/games/domain/models/game.dart';
import '../utils/platform_icon_mapper.dart';
import 'game_cover_hero.dart';
import 'shimmer.dart';

class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    required this.game,
    this.heroTag,
    this.onTap,
    this.fill = false,
    this.priceLabel,
    this.priceLoading = false,
    this.frameColor,
    this.badgeLabel,
    this.badgeColor,
  });

  static const double width = 152;
  static const double height = 228;

  final Game game;
  final String? heroTag;
  final VoidCallback? onTap;
  final bool fill;
  final String? priceLabel;
  final bool priceLoading;
  final Color? frameColor;
  final String? badgeLabel;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    final tag = heroTag ?? 'game-cover-${game.id}';

    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: frameColor ?? AppColors.outline,
              width: frameColor == null ? 1 : 1.4,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x73000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                GameCoverHero(
                  tag: tag,
                  child: Material(
                    color: AppColors.surfaceHigh,
                    child: _Cover(url: game.coverUrl),
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x00000000),
                        Color(0x66000000),
                        Color(0xF207080B),
                      ],
                      stops: [0.42, 0.68, 1.0],
                    ),
                  ),
                ),
                if (badgeLabel != null && badgeColor != null)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _FameBadge(
                      label: badgeLabel!,
                      color: badgeColor!,
                    ),
                  ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: PlatformIconMapper.row(
                          slugs: game.platformSlugs,
                          names: game.platforms,
                          size: 16,
                        ),
                      ),
                      if (PlatformIconMapper.uniqueSlugs(
                        game.platformSlugs.isNotEmpty
                            ? game.platformSlugs
                            : game.platforms,
                      ).isNotEmpty)
                        const SizedBox(height: 6),
                      Text(
                        game.name,
                        maxLines: priceLoading || priceLabel != null ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      if (priceLoading || priceLabel != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: DealPriceTag(
                            label: priceLabel,
                            loading: priceLoading,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (fill) {
      return SizedBox.expand(child: card);
    }

    return SizedBox(
      width: width,
      height: height,
      child: card,
    );
  }
}

class _FameBadge extends StatelessWidget {
  const _FameBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: const Color(0xFF121212),
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class GameListRow extends StatelessWidget {
  const GameListRow({
    super.key,
    required this.game,
    required this.heroTag,
    required this.onTap,
    this.priceLabel,
    this.priceLoading = false,
  });

  final Game game;
  final String heroTag;
  final VoidCallback onTap;
  final String? priceLabel;
  final bool priceLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              GameCoverHero(
                tag: heroTag,
                cornerRadius: 12,
                child: Material(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    width: 64,
                    height: 86,
                    child: _Cover(url: game.coverUrl),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    if (priceLoading || priceLabel != null) ...[
                      const SizedBox(height: 8),
                      DealPriceTag(label: priceLabel, loading: priceLoading),
                    ],
                    const SizedBox(height: 8),
                    PlatformIconMapper.row(
                      slugs: game.platformSlugs,
                      names: game.platforms,
                      size: 16,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.onSurfaceMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DealPriceTag extends StatelessWidget {
  const DealPriceTag({
    super.key,
    required this.label,
    this.loading = false,
  });

  static const Color _green = Color(0xFF4ADE80);
  static const Color _greenSurface = Color(0xFF163323);

  final String? label;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 1.8,
          color: _green,
        ),
      );
    }
    if (label == null || label!.isEmpty) {
      return const SizedBox.shrink();
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _greenSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _green.withValues(alpha: 0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          '🏷️ $label',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: _green,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

class GameCardSkeleton extends StatelessWidget {
  const GameCardSkeleton({super.key, this.fill = false});

  final bool fill;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.all(Radius.circular(18)),
    );

    return Shimmer(
      child: fill
          ? SizedBox.expand(child: DecoratedBox(decoration: decoration))
          : SizedBox(
              width: GameCard.width,
              height: GameCard.height,
              child: DecoratedBox(decoration: decoration),
            ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return ColoredBox(color: AppColors.surfaceHigh);
    }

    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      fadeInDuration: Duration.zero,
      placeholder: (context, _) {
        return ColoredBox(color: AppColors.surfaceHigh);
      },
      errorWidget: (context, _, _) {
        return ColoredBox(color: AppColors.surface);
      },
    );
  }
}
