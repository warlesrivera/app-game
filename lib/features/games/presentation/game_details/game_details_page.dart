import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/platform_icon_mapper.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../library/domain/models/library_entry.dart';
import '../../../library/domain/models/library_status.dart';
import '../../../library/presentation/cubit/library_cubit.dart';
import '../../../library/presentation/cubit/library_state.dart';
import '../../domain/models/game.dart';
import '../../domain/models/game_video.dart';
import 'game_details_cubit.dart';
import 'game_details_state.dart';

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
    required this.heroTag,
  });

  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<GameDetailsCubit, GameDetailsState>(
        builder: (context, state) {
          final game = state.game;
          final textTheme = Theme.of(context).textTheme;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _HeroHeader(game: game, heroTag: heroTag),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
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
                      if (state.error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          state.error!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      _DetailsSections(state: state),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailsSections extends StatefulWidget {
  const _DetailsSections({required this.state});

  final GameDetailsState state;

  @override
  State<_DetailsSections> createState() => _DetailsSectionsState();
}

class _DetailsSectionsState extends State<_DetailsSections> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: [
            _SectionChip(
              label: 'Detalles',
              selected: _index == 0,
              onTap: () => setState(() => _index = 0),
            ),
            _SectionChip(
              label: 'Tráilers',
              selected: _index == 1,
              onTap: () => setState(() => _index = 1),
            ),
            _SectionChip(
              label: 'Guía',
              selected: _index == 2,
              onTap: () {
                context.read<GameDetailsCubit>().loadGuide();
                setState(() => _index = 2);
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        switch (_index) {
          1 => _TrailerPanel(state: widget.state),
          2 => _GuidePanel(state: widget.state),
          _ => _DetailsPanel(state: widget.state),
        },
      ],
    );
  }
}

class _SectionChip extends StatelessWidget {
  const _SectionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
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
  }
}

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel({required this.state});

  final GameDetailsState state;

  @override
  Widget build(BuildContext context) {
    final game = state.game;
    final textTheme = Theme.of(context).textTheme;
    final synopsis = state.synopsis;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PlatformRow(
          slugs: game.platformSlugs,
          names: game.platforms,
        ),
        const SizedBox(height: 20),
        _MetaRow(game: game),
        const SizedBox(height: 28),
        const _SectionTitle('TRÁILERS'),
        const SizedBox(height: 14),
        _VideosRow(state: state),
        const SizedBox(height: 28),
        _ScreenshotGallery(urls: game.screenshotUrls),
        if (game.screenshotUrls.isNotEmpty) const SizedBox(height: 28),
        const _SectionTitle('SINOPSIS'),
        const SizedBox(height: 12),
        if (state.loadingDescription ||
            (state.translating && !_hasText(game.descriptionEs)))
          const _ShimmerLines()
        else if (synopsis != null)
          Text(
            synopsis,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurface,
              height: 1.55,
            ),
          )
          else
          Text(
            'No hay descripción disponible.',
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurfaceMuted,
              height: 1.55,
            ),
          ),
        const SizedBox(height: 28),
        _NamedListSection(
          title: 'DESARROLLADORES',
          values: game.developers,
        ),
        _NamedListSection(
          title: 'PUBLISHERS',
          values: game.publishers,
        ),
        _NamedListSection(
          title: 'TIENDAS',
          values: game.stores,
        ),
        if (_hasText(game.website)) ...[
          const SizedBox(height: 28),
          const _SectionTitle('WEB OFICIAL'),
          const SizedBox(height: 12),
          _WebsiteButton(url: game.website!),
        ],
        if (game.tags.isNotEmpty) ...[
          const SizedBox(height: 28),
          const _SectionTitle('TAGS'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in game.tags) _TagChip(label: tag),
            ],
          ),
        ],
      ],
    );
  }
}

class _TrailerPanel extends StatelessWidget {
  const _TrailerPanel({required this.state});

  final GameDetailsState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('TRÁILERS'),
        const SizedBox(height: 14),
        _VideosRow(state: state),
      ],
    );
  }
}

class _VideosRow extends StatelessWidget {
  const _VideosRow({required this.state});

  final GameDetailsState state;

  @override
  Widget build(BuildContext context) {
    if (state.loadingVideos) {
      return SizedBox(
        height: 148,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, _) => const _ShimmerShot(),
        ),
      );
    }

    if (state.videos.isEmpty) {
      return _YoutubeTrailerFallback(
        gameName: state.game.name,
        coverUrl: state.game.coverUrl,
      );
    }

    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: state.videos.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final video = state.videos[index];
          return _VideoThumbnail(video: video);
        },
      ),
    );
  }
}

class _VideoThumbnail extends StatelessWidget {
  const _VideoThumbnail({required this.video});

  final GameVideo video;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: video.url.isEmpty ? null : () => _open(video.url),
      child: SizedBox(
        width: 260,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (video.preview.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: video.preview,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => const ColoredBox(
                          color: AppColors.surfaceHigh,
                        ),
                        errorWidget: (_, _, _) => const ColoredBox(
                          color: AppColors.surfaceHigh,
                        ),
                      )
                    else
                      const ColoredBox(color: AppColors.surfaceHigh),
                    const ColoredBox(color: Color(0x66000000)),
                    const Center(
                      child: Icon(
                        Icons.play_circle_fill_rounded,
                        size: 56,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (video.name.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                video.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _open(String url) async {
    await _openExternalUrl(url);
  }
}

class _YoutubeTrailerFallback extends StatelessWidget {
  const _YoutubeTrailerFallback({
    required this.gameName,
    required this.coverUrl,
  });

  final String gameName;
  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _openExternalUrl(_youtubeSearchUrl(gameName)),
          child: SizedBox(
            height: 148,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (coverUrl != null && coverUrl!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: coverUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => const ColoredBox(
                        color: AppColors.surfaceHigh,
                      ),
                      errorWidget: (_, _, _) => const ColoredBox(
                        color: AppColors.surfaceHigh,
                      ),
                    )
                  else
                    const ColoredBox(color: AppColors.surfaceHigh),
                  const ColoredBox(color: Color(0x99000000)),
                  const Center(
                    child: Icon(
                      Icons.play_circle_fill_rounded,
                      size: 64,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'RAWG no incluye un archivo de tráiler para este juego. '
          'Ábrelo en YouTube.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceMuted,
          ),
        ),
      ],
    );
  }
}

class _GuidePanel extends StatelessWidget {
  const _GuidePanel({required this.state});

  final GameDetailsState state;

  @override
  Widget build(BuildContext context) {
    if (state.loadingGuide && state.guide == null) {
      return const _ShimmerLines();
    }

    final guide = state.guide;
    if (guide == null || guide.isEmpty) {
      return Text(
        'RAWG no trae walkthroughs. Buscamos un resumen en Wikipedia '
        'y enlaces a guías externas.',
        style: Theme.of(context).textTheme.bodyLarge,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('GUÍA'),
        const SizedBox(height: 8),
        Text(
          guide.sourceLabel == 'Wikipedia'
              ? 'Resumen de Wikipedia (RAWG no incluye guías).'
              : 'Guía de inicio. RAWG no incluye walkthroughs.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (guide.hasText) ...[
          const SizedBox(height: 16),
          Text(
            guide.summary!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.55,
            ),
          ),
        ],
        const SizedBox(height: 24),
        const _SectionTitle('MÁS GUÍAS'),
        const SizedBox(height: 12),
        if (guide.wikiUrl != null)
          _GuideLinkButton(
            label: 'Wikipedia',
            url: guide.wikiUrl!,
          ),
        if (guide.walkthroughUrl != null)
          _GuideLinkButton(
            label: 'Walkthroughs en GameFAQs',
            url: guide.walkthroughUrl!,
          ),
        if (guide.ignUrl != null)
          _GuideLinkButton(
            label: 'Buscar en IGN',
            url: guide.ignUrl!,
          ),
        if (guide.redditUrl != null)
          _GuideLinkButton(
            label: 'Comunidad en Reddit',
            url: guide.redditUrl!,
          ),
      ],
    );
  }
}

class _GuideLinkButton extends StatelessWidget {
  const _GuideLinkButton({
    required this.label,
    required this.url,
  });

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton.icon(
        onPressed: () => _openExternalUrl(url),
        icon: const Icon(Icons.open_in_new_rounded),
        label: Text(label),
      ),
    );
  }
}


bool _hasText(String? value) {
  return value != null && value.trim().isNotEmpty;
}

String _youtubeSearchUrl(String gameName) {
  final query = Uri.encodeQueryComponent('$gameName official trailer');
  return 'https://www.youtube.com/results?search_query=$query';
}

Future<void> _openExternalUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    return;
  }
  await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
    webOnlyWindowName: '_blank',
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: AppColors.accent,
        letterSpacing: 2.2,
      ),
    );
  }
}

class _NamedListSection extends StatelessWidget {
  const _NamedListSection({
    required this.title,
    required this.values,
  });

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title),
          const SizedBox(height: 12),
          Text(
            values.join('  ·  '),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _WebsiteButton extends StatelessWidget {
  const _WebsiteButton({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _openExternalUrl(url),
      icon: const Icon(Icons.open_in_new_rounded),
      label: Text(url, overflow: TextOverflow.ellipsis),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

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
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.onSurfaceMuted,
          ),
        ),
      ),
    );
  }
}

class _ScreenshotGallery extends StatelessWidget {
  const _ScreenshotGallery({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('CAPTURAS'),
        const SizedBox(height: 14),
        SizedBox(
          height: 148,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: urls.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final url = urls[index];
              return GestureDetector(
                onTap: () => _openLightbox(context, urls, index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(milliseconds: 280),
                      placeholder: (_, _) => const ColoredBox(
                        color: AppColors.surfaceHigh,
                      ),
                      errorWidget: (_, _, _) => const ColoredBox(
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openLightbox(BuildContext context, List<String> urls, int index) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: const Color(0xE607080B),
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, animation, _) {
          return FadeTransition(
            opacity: animation,
            child: _ScreenshotLightbox(
              urls: urls,
              initialIndex: index,
            ),
          );
        },
      ),
    );
  }
}

class _ScreenshotLightbox extends StatefulWidget {
  const _ScreenshotLightbox({
    required this.urls,
    required this.initialIndex,
  });

  final List<String> urls;
  final int initialIndex;

  @override
  State<_ScreenshotLightbox> createState() => _ScreenshotLightboxState();
}

class _ScreenshotLightboxState extends State<_ScreenshotLightbox> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.urls.length,
              onPageChanged: (value) => setState(() => _index = value),
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: widget.urls[index],
                      fit: BoxFit.contain,
                      placeholder: (_, _) => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                tooltip: 'Cerrar',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                color: AppColors.onSurface,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  '${_index + 1} / ${widget.urls.length}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerShot extends StatelessWidget {
  const _ShimmerShot();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const SizedBox(width: 240, height: 148),
      ),
    );
  }
}

class _ShimmerLines extends StatelessWidget {
  const _ShimmerLines();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        children: [
          for (var i = 0; i < 4; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SizedBox(
                height: 14,
                width: i == 3 ? 180 : double.infinity,
              ),
            ),
          ],
        ],
      ),
    );
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
  static const _stores = ['Steam', 'PlayStation', 'Xbox', 'Nintendo', 'Epic'];

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
  const _PlatformRow({
    required this.slugs,
    required this.names,
  });

  final List<String> slugs;
  final List<String> names;

  @override
  Widget build(BuildContext context) {
    return PlatformIconMapper.row(
      slugs: slugs,
      names: names,
      size: 20,
      spacing: 10,
      color: AppColors.onSurface,
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
          label: game.ratingsCount != null && game.ratingsCount! > 0
              ? '${game.rating!.toStringAsFixed(1)}  (${game.ratingsCount})'
              : game.rating!.toStringAsFixed(1),
        ),
      if (game.metacritic != null && game.metacritic! > 0)
        _MetaChip(
          icon: Icons.verified_outlined,
          label: 'Metacritic ${game.metacritic}',
        ),
      if (game.playtime != null && game.playtime! > 0)
        _MetaChip(
          icon: Icons.schedule_outlined,
          label: '${game.playtime} h',
        ),
      if (_hasText(game.esrbRating))
        _MetaChip(
          icon: Icons.shield_outlined,
          label: game.esrbRating!,
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
