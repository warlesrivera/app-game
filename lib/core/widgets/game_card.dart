import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../features/games/domain/models/game.dart';
import 'shimmer.dart';

class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    required this.game,
    this.heroTag,
    this.onTap,
  });

  static const double width = 152;
  static const double height = 228;

  final Game game;
  final String? heroTag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tag = heroTag ?? 'game-cover-${game.id}';

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.outline),
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
                  Hero(
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
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 14,
                    child: Text(
                      game.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GameCardSkeleton extends StatelessWidget {
  const GameCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SizedBox(
        width: GameCard.width,
        height: GameCard.height,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
        ),
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
