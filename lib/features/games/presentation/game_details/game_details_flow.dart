import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection.dart';
import '../../domain/models/game.dart';
import 'game_details_cubit.dart';
import 'game_details_page.dart';

class GameDetailsFlow extends StatefulWidget {
  const GameDetailsFlow({
    super.key,
    required this.games,
    required this.initialIndex,
    required this.heroTag,
  });

  final List<Game> games;
  final int initialIndex;
  final String heroTag;

  @override
  State<GameDetailsFlow> createState() => _GameDetailsFlowState();
}

class _GameDetailsFlowState extends State<GameDetailsFlow> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.games.length - 1);
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.games.length == 1) {
      return _GamePage(
        game: widget.games.first,
        heroTag: widget.heroTag,
      );
    }

    return PageView.builder(
      controller: _controller,
      itemCount: widget.games.length,
      physics: const BouncingScrollPhysics(
        parent: PageScrollPhysics(),
      ),
      onPageChanged: (index) => setState(() => _index = index),
      itemBuilder: (context, index) {
        final game = widget.games[index];
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            var page = _index.toDouble();
            if (_controller.hasClients &&
                _controller.position.hasContentDimensions) {
              page = _controller.page ?? page;
            }
            final delta = page - index;
            final distance = delta.abs();
            final scale = 1 - (distance * 0.05).clamp(0.0, 0.08);
            final opacity = (1 - distance * 0.32).clamp(0.58, 1.0);

            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(delta * 36, 0),
                child: Transform.scale(
                  scale: scale,
                  child: child,
                ),
              ),
            );
          },
          child: _GamePage(
            game: game,
            heroTag: index == widget.initialIndex
                ? widget.heroTag
                : 'queue-${game.id}-$index',
          ),
        );
      },
    );
  }
}

class _GamePage extends StatelessWidget {
  const _GamePage({
    required this.game,
    required this.heroTag,
  });

  final Game game;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<GameDetailsCubit>(
        param1: game,
        param2: heroTag,
      )..load(),
      child: GameDetailsPage(heroTag: heroTag),
    );
  }
}
