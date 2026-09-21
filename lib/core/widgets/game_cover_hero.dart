import 'dart:ui';

import 'package:flutter/material.dart';

class GameCoverHero extends StatelessWidget {
  const GameCoverHero({
    super.key,
    required this.tag,
    required this.child,
    this.cornerRadius = 18,
  });

  final String tag;
  final Widget child;
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      createRectTween: (begin, end) => MaterialRectArcTween(
        begin: begin,
        end: end,
      ),
      transitionOnUserGestures: true,
      flightShuttleBuilder: (
        flightContext,
        animation,
        direction,
        fromHeroContext,
        toHeroContext,
      ) {
        final toHero = toHeroContext.widget as Hero;
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final t = Curves.easeInOutCubic.transform(animation.value);
            final radius = direction == HeroFlightDirection.push
                ? lerpDouble(cornerRadius, 0, t)!
                : lerpDouble(0, cornerRadius, t)!;
            return ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: child,
            );
          },
          child: toHero.child,
        );
      },
      child: child,
    );
  }
}
