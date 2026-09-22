import 'package:flutter/material.dart';

import '../../features/games/domain/models/game.dart';
import 'game_card.dart';

class GameGrid extends StatelessWidget {
  const GameGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = const EdgeInsets.fromLTRB(12, 0, 12, 16),
    this.physics,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final EdgeInsets padding;
  final ScrollPhysics? physics;

  static const double _gap = 8;

  static const SliverGridDelegate delegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: GameCard.width + _gap,
    mainAxisExtent: GameCard.height,
    mainAxisSpacing: _gap,
    crossAxisSpacing: _gap,
  );

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      physics: physics,
      gridDelegate: delegate,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

class GameGridCard extends StatelessWidget {
  const GameGridCard({
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
    return GameCard(
      game: game,
      heroTag: heroTag,
      fill: true,
      onTap: onTap,
      priceLabel: priceLabel,
      priceLoading: priceLoading,
    );
  }
}
