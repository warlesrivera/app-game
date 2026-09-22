import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../features/games/domain/models/game.dart';
import '../../../features/games/presentation/game_details/game_details_page.dart';
import 'game_card.dart';

class CatalogGamesRow extends StatefulWidget {
  const CatalogGamesRow({
    super.key,
    required this.title,
    required this.games,
    this.heroPrefix = 'discover',
    this.onTitleTap,
  });

  final String title;
  final List<Game> games;
  final String heroPrefix;
  final VoidCallback? onTitleTap;

  @override
  State<CatalogGamesRow> createState() => _CatalogGamesRowState();
}

class _CatalogGamesRowState extends State<CatalogGamesRow> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_controller.hasClients) {
      return;
    }

    final next = (_controller.offset + event.scrollDelta.dy + event.scrollDelta.dx)
        .clamp(0.0, _controller.position.maxScrollExtent);
    _controller.jumpTo(next);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.games.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
          child: widget.onTitleTap == null
              ? Text(
                  widget.title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.accent,
                    letterSpacing: 2.2,
                  ),
                )
              : InkWell(
                  onTap: widget.onTitleTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: AppColors.accent,
                                  letterSpacing: 2.2,
                                ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.accent,
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        SizedBox(
          height: GameCard.height,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              scrollbars: false,
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
                PointerDeviceKind.stylus,
              },
            ),
            child: Listener(
              onPointerSignal: _onPointerSignal,
              child: ListView.builder(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: widget.games.length,
                itemExtent: GameCard.width + 8,
                itemBuilder: (context, index) {
                  final game = widget.games[index];
                  final heroTag =
                      '${widget.heroPrefix}-${widget.title}-${game.id}';
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GameCard(
                      game: game,
                      heroTag: heroTag,
                      onTap: () => openGameDetails(
                        context,
                        game,
                        heroTag: heroTag,
                        queue: widget.games,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CatalogGamesRowSkeleton extends StatelessWidget {
  const CatalogGamesRowSkeleton({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.accent,
              letterSpacing: 2.2,
            ),
          ),
        ),
        SizedBox(
          height: GameCard.height,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 8,
            itemExtent: GameCard.width + 8,
            itemBuilder: (_, _) => const Padding(
              padding: EdgeInsets.only(right: 8),
              child: GameCardSkeleton(),
            ),
          ),
        ),
      ],
    );
  }
}
