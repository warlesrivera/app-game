import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/navigation/page_curl_math.dart';
import '../../../../core/navigation/page_curl_transition.dart';
import '../../../../core/utils/platform_icon_mapper.dart';
import '../../../../core/widgets/game_card.dart';
import '../../../../core/widgets/game_cover_hero.dart';
import '../../../../core/widgets/in_app_browser_page.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../library/domain/models/library_entry.dart';
import '../../../library/domain/models/library_status.dart';
import '../../../library/presentation/cubit/library_cubit.dart';
import '../../../library/presentation/cubit/library_state.dart';
import '../../../prices/domain/models/game_deal.dart';
import '../../domain/models/game.dart';
import 'game_details_cubit.dart';
import 'game_details_state.dart';

class GameDetailsArgs {
  const GameDetailsArgs({
    required this.game,
    required this.heroTag,
    this.queue = const [],
  });

  final Game game;
  final String heroTag;
  final List<Game> queue;

  List<Game> get pages {
    if (queue.length > 1) {
      return queue;
    }
    return [game];
  }

  int get initialIndex {
    final pages = this.pages;
    final index = pages.indexWhere((item) => item.id == game.id);
    return index < 0 ? 0 : index;
  }

  static GameDetailsArgs? tryParse(Object? extra) {
    if (extra is GameDetailsArgs) {
      return extra;
    }
    if (extra is Game) {
      return GameDetailsArgs(game: extra, heroTag: 'game-cover-${extra.id}');
    }
    return null;
  }
}

void openGameDetails(
  BuildContext context,
  Game game, {
  required String heroTag,
  List<Game> queue = const [],
}) {
  context.pushNamed(
    'gameDetails',
    pathParameters: {'id': game.id},
    extra: GameDetailsArgs(game: game, heroTag: heroTag, queue: queue),
  );
}

class GameDetailsPage extends StatelessWidget {
  const GameDetailsPage({super.key, required this.heroTag});

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
                  child: _ContentReveal(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                game.name,
                                style: textTheme.displaySmall?.copyWith(
                                  letterSpacing: -0.8,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            _FavoriteButton(gameId: game.id),
                          ],
                        ),
                        _DealBanner(state: state),
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
              label: 'Lore',
              selected: _index == 1,
              onTap: () {
                context.read<GameDetailsCubit>().loadLore();
                setState(() => _index = 1);
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        switch (_index) {
          1 => _LorePanel(state: widget.state),
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
      side: BorderSide(color: selected ? AppColors.accent : AppColors.outline),
      labelStyle: TextStyle(
        color: selected ? AppColors.onSurface : AppColors.onSurfaceMuted,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _LorePanel extends StatelessWidget {
  const _LorePanel({required this.state});

  final GameDetailsState state;

  @override
  Widget build(BuildContext context) {
    if (state.loadingLore && state.lore == null) {
      return const _ShimmerLines();
    }

    final html = state.lore?.content;
    if (html == null || html.isEmpty) {
      return Text(
        'Lore no disponible en los archivos.',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.onSurfaceMuted,
          height: 1.55,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('LORE'),
        const SizedBox(height: 8),
        Text(
          'Archivo de Wikipedia. Pela la esquina de la hoja como en un libro.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceMuted),
        ),
        const SizedBox(height: 14),
        _LoreBook(html: html),
        if (state.lore?.wikiUrl != null) ...[
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => openInAppWeb(
                context,
                state.lore!.wikiUrl!,
                title: 'Wikipedia',
              ),
              icon: const Icon(Icons.public_rounded),
              label: const Text('Leer en Wikipedia'),
            ),
          ),
        ],
      ],
    );
  }
}

class _LoreBook extends StatefulWidget {
  const _LoreBook({required this.html});

  final String html;

  @override
  State<_LoreBook> createState() => _LoreBookState();
}

class _LoreBookState extends State<_LoreBook>
    with SingleTickerProviderStateMixin {
  late final AnimationController _curl;
  late List<_LoreLeaf> _pages;
  var _index = 0;
  var _forward = true;
  var _busy = false;
  var _dragging = false;
  var _dragDx = 0.0;
  Offset? _pointer;
  Widget? _frontLeaf;
  Widget? _backLeaf;

  PageCurlOrigin get _origin => _forward
      ? PageCurlOrigin.bottomRight
      : PageCurlOrigin.bottomLeft;

  @override
  void initState() {
    super.initState();
    _pages = _splitLoreLeaves(widget.html);
    _curl = AnimationController(vsync: this);
    _curl.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(covariant _LoreBook oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.html == widget.html) {
      return;
    }
    _pages = _splitLoreLeaves(widget.html);
    _index = _index.clamp(0, _pages.length - 1);
  }

  @override
  void dispose() {
    _curl.dispose();
    super.dispose();
  }

  Future<void> _turnTo(int next) async {
    if (_busy || next == _index || next < 0 || next >= _pages.length) {
      return;
    }
    final forward = next > _index;
    if (MediaQuery.disableAnimationsOf(context)) {
      setState(() => _index = next);
      return;
    }
    setState(() {
      _busy = true;
      _forward = forward;
      _pointer = null;
      _frontLeaf = _sheet(index: _index, scrollable: false);
      _backLeaf = _sheet(index: next, scrollable: false);
    });
    await _curl.animateTo(
      1,
      duration: const Duration(milliseconds: 720),
      curve: Curves.easeInCubic,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _index = next;
      _busy = false;
      _frontLeaf = null;
      _backLeaf = null;
    });
    _curl.value = 0;
  }

  void _beginCurl({
    required bool forward,
    required Size size,
    required Offset local,
  }) {
    final next = forward ? _index + 1 : _index - 1;
    if (_busy || next < 0 || next >= _pages.length) {
      return;
    }
    _dragging = true;
    _busy = true;
    _forward = forward;
    _pointer = local;
    _frontLeaf = _sheet(index: _index, scrollable: false);
    _backLeaf = _sheet(index: next, scrollable: false);
    _curl.stop();
    _curl.value = PageCurlGeometry.progressFromPointer(
      size,
      local,
      origin: _origin,
    );
    setState(() {});
  }

  void _settle({required bool complete, required double velocity}) {
    final next = _forward ? _index + 1 : _index - 1;
    final canComplete = complete && next >= 0 && next < _pages.length;
    final target = canComplete ? 1.0 : 0.0;
    final distance = (target - _curl.value).abs();
    _pointer = null;
    _curl
        .animateTo(
          target,
          duration: Duration(
            milliseconds: (420 + distance * 260 - velocity.abs() * 0.04)
                .clamp(240, 720)
                .round(),
          ),
          curve: canComplete ? Curves.easeInCubic : Curves.easeOutCubic,
        )
        .whenComplete(() {
          if (!mounted) {
            return;
          }
          setState(() {
            if (canComplete) {
              _index = next;
            }
            _busy = false;
            _dragging = false;
            _frontLeaf = null;
            _backLeaf = null;
          });
          _curl.value = 0;
        });
  }

  void _onCornerEnd(DragEndDetails details) {
    if (!_dragging) {
      return;
    }
    _dragging = false;
    final vx = details.velocity.pixelsPerSecond.dx;
    final flung = _forward ? vx < -700 : vx > 700;
    _settle(complete: _curl.value > 0.28 || flung, velocity: vx);
  }

  void _onSwipeEnd(DragEndDetails details) {
    if (_busy || _dragging) {
      return;
    }
    final velocity = details.velocity.pixelsPerSecond;
    final horizontal =
        velocity.dx.abs() > 260 && velocity.dx.abs() > velocity.dy.abs() * 0.8;
    if (horizontal) {
      if (velocity.dx < 0) {
        _turnTo(_index + 1);
      } else {
        _turnTo(_index - 1);
      }
      _dragDx = 0;
      return;
    }
    if (_dragDx <= -56) {
      _turnTo(_index + 1);
    } else if (_dragDx >= 56) {
      _turnTo(_index - 1);
    }
    _dragDx = 0;
  }

  @override
  Widget build(BuildContext context) {
    final peek = _forward ? _index + 1 : _index - 1;
    final backIndex = peek.clamp(0, _pages.length - 1);

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 0.78,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.biggest;
              return GestureDetector(
                onHorizontalDragStart: (_) {
                  if (!_busy) {
                    _dragDx = 0;
                  }
                },
                onHorizontalDragUpdate: (details) {
                  if (!_busy) {
                    _dragDx += details.delta.dx;
                  }
                },
                onHorizontalDragEnd: _onSwipeEnd,
                child: Stack(
                  clipBehavior: Clip.none,
                  fit: StackFit.expand,
                  children: [
                    PageCurlLayer(
                      progress: _curl.value.clamp(0.0, 1.0),
                      pointer: _dragging ? _pointer : null,
                      origin: _origin,
                      front:
                          _frontLeaf ??
                          _sheet(index: _index, scrollable: !_busy),
                      back:
                          _backLeaf ??
                          _sheet(index: backIndex, scrollable: false),
                    ),
                    if (!_busy && _index < _pages.length - 1)
                      const _CurlHint(),
                    if (!_busy && _index > 0)
                      const _CurlHint(alignment: Alignment.bottomLeft),
                    if (_index < _pages.length - 1)
                      _CornerCurlHandle(
                        alignment: Alignment.bottomRight,
                        size: size,
                        onStart: (local) => _beginCurl(
                          forward: true,
                          size: size,
                          local: local,
                        ),
                        onUpdate: (local) {
                          if (!_dragging) {
                            return;
                          }
                          _pointer = local;
                          _curl.value = PageCurlGeometry.progressFromPointer(
                            size,
                            local,
                            origin: PageCurlOrigin.bottomRight,
                          );
                        },
                        onEnd: _onCornerEnd,
                      ),
                    if (_index > 0)
                      _CornerCurlHandle(
                        alignment: Alignment.bottomLeft,
                        size: size,
                        onStart: (local) => _beginCurl(
                          forward: false,
                          size: size,
                          local: local,
                        ),
                        onUpdate: (local) {
                          if (!_dragging) {
                            return;
                          }
                          _pointer = local;
                          _curl.value = PageCurlGeometry.progressFromPointer(
                            size,
                            local,
                            origin: PageCurlOrigin.bottomLeft,
                          );
                        },
                        onEnd: _onCornerEnd,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              tooltip: 'Hoja anterior',
              onPressed: _index == 0 || _busy
                  ? null
                  : () => _turnTo(_index - 1),
              icon: const Icon(Icons.chevron_left_rounded),
              color: AppColors.accent,
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: (_index + 1) / _pages.length,
                  minHeight: 4,
                  color: AppColors.accent,
                  backgroundColor: AppColors.surfaceHigh,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Hoja siguiente',
              onPressed: _index >= _pages.length - 1 || _busy
                  ? null
                  : () => _turnTo(_index + 1),
              icon: const Icon(Icons.chevron_right_rounded),
              color: AppColors.accent,
            ),
          ],
        ),
      ],
    );
  }

  Widget _sheet({required int index, bool? scrollable}) {
    return _LoreSheet(
      leaf: _pages[index],
      pageLabel: '${index + 1} / ${_pages.length}',
      scrollable: scrollable ?? !_busy,
    );
  }
}

class _CornerCurlHandle extends StatelessWidget {
  const _CornerCurlHandle({
    required this.alignment,
    required this.size,
    required this.onStart,
    required this.onUpdate,
    required this.onEnd,
  });

  final Alignment alignment;
  final Size size;
  final ValueChanged<Offset> onStart;
  final ValueChanged<Offset> onUpdate;
  final GestureDragEndCallback onEnd;

  @override
  Widget build(BuildContext context) {
    final zone = (size.shortestSide * 0.22).clamp(72.0, 140.0);
    final fromRight = alignment == Alignment.bottomRight;

    Offset toBook(Offset local) {
      return Offset(
        fromRight ? size.width - zone + local.dx : local.dx,
        size.height - zone + local.dy,
      );
    }

    return Align(
      alignment: alignment,
      child: SizedBox(
        width: zone,
        height: zone,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) => onStart(toBook(details.localPosition)),
          onPanUpdate: (details) => onUpdate(toBook(details.localPosition)),
          onPanEnd: onEnd,
          onPanCancel: () => onEnd(DragEndDetails()),
        ),
      ),
    );
  }
}

class _CurlHint extends StatelessWidget {
  const _CurlHint({this.alignment = Alignment.bottomRight});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final flipped = alignment == Alignment.bottomLeft;
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Transform.flip(
          flipX: flipped,
          child: const CustomPaint(
            size: Size(42, 42),
            painter: _CurlHintPainter(),
          ),
        ),
      ),
    );
  }
}

class _CurlHintPainter extends CustomPainter {
  const _CurlHintPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF2A2430));
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.18, size.height)
        ..quadraticBezierTo(
          size.width * 0.55,
          size.height * 0.55,
          size.width,
          size.height * 0.18,
        )
        ..lineTo(size.width, size.height)
        ..close(),
      Paint()..color = const Color(0x44D4AF37),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LoreSheet extends StatelessWidget {
  const _LoreSheet({
    required this.leaf,
    required this.pageLabel,
    required this.scrollable,
  });

  final _LoreLeaf leaf;
  final String pageLabel;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF16141A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.28)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      leaf.title ?? 'Archivo',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  Text(
                    pageLabel,
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.outline),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                physics: scrollable
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                child: Html(
                  data: leaf.html,
                  shrinkWrap: true,
                  onLinkTap: (url, _, _) {
                    if (url == null || url.isEmpty) {
                      return;
                    }
                    final resolved = url.startsWith('http')
                        ? url
                        : 'https://es.wikipedia.org$url';
                    openInAppWeb(context, resolved, title: 'Wikipedia');
                  },
                  style: {
                    'body': Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      color: AppColors.onSurface,
                      fontSize: FontSize(textTheme.bodyLarge?.fontSize ?? 16),
                      lineHeight: const LineHeight(1.55),
                    ),
                    'p': Style(
                      margin: Margins.only(bottom: 12),
                      color: AppColors.onSurface,
                    ),
                    'h2': Style(
                      color: AppColors.accent,
                      fontSize: FontSize(17),
                      fontWeight: FontWeight.w700,
                      margin: Margins.only(bottom: 10),
                    ),
                    'h3': Style(
                      color: AppColors.accent,
                      fontSize: FontSize(15),
                      fontWeight: FontWeight.w700,
                      margin: Margins.only(bottom: 8),
                    ),
                    'a': Style(
                      color: AppColors.accent,
                      textDecoration: TextDecoration.none,
                    ),
                    'li': Style(
                      color: AppColors.onSurface,
                      margin: Margins.only(bottom: 6),
                    ),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoreLeaf {
  const _LoreLeaf({this.title, required this.html});

  final String? title;
  final String html;
}

List<_LoreLeaf> _splitLoreLeaves(String html) {
  const maxChars = 900;
  final sections = html.split(RegExp(r'(?=<h[23]\b)', caseSensitive: false));
  final pages = <_LoreLeaf>[];

  for (final raw in sections) {
    final section = raw.trim();
    if (section.isEmpty) {
      continue;
    }
    final heading = RegExp(
      r'<h[23][^>]*>(.*?)</h[23]>',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(section);
    final title = heading == null ? null : _plainText(heading.group(1)!);
    final body = heading == null
        ? section
        : section.substring(heading.end).trim();
    final chunks = _chunkHtml(body, maxChars);
    if (chunks.isEmpty) {
      if (title != null && title.isNotEmpty) {
        pages.add(_LoreLeaf(title: title, html: '<p></p>'));
      }
      continue;
    }
    for (var index = 0; index < chunks.length; index += 1) {
      pages.add(
        _LoreLeaf(
          title: index == 0 || title == null ? title : '$title · cont.',
          html: chunks[index],
        ),
      );
    }
  }

  if (pages.isEmpty) {
    return [_LoreLeaf(html: html)];
  }
  return pages;
}

List<String> _chunkHtml(String html, int maxChars) {
  final trimmed = html.trim();
  if (trimmed.isEmpty) {
    return const [];
  }
  if (trimmed.length <= maxChars) {
    return [trimmed];
  }

  final blocks = trimmed.split(
    RegExp(r'(?=<p\b|<li\b|<ul\b|<ol\b)', caseSensitive: false),
  );
  if (blocks.length <= 1) {
    return [trimmed];
  }

  final chunks = <String>[];
  final buffer = StringBuffer();
  for (final block in blocks) {
    final piece = block.trim();
    if (piece.isEmpty) {
      continue;
    }
    if (buffer.length + piece.length > maxChars && buffer.isNotEmpty) {
      chunks.add(buffer.toString());
      buffer
        ..clear()
        ..write(piece);
      continue;
    }
    buffer.write(piece);
  }
  if (buffer.isNotEmpty) {
    chunks.add(buffer.toString());
  }
  return chunks;
}

String _plainText(String html) {
  return html
      .replaceAll(RegExp(r'<[^>]+>'), '')
      .replaceAll('&amp;', '&')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&quot;', '"')
      .trim();
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
        _PlatformRow(slugs: game.platformSlugs, names: game.platforms),
        const SizedBox(height: 20),
        _MetaRow(game: game),
        const SizedBox(height: 28),
        const _SectionTitle('TRÁILERS'),
        const SizedBox(height: 14),
        _YoutubeTrailerCard(gameName: game.name, coverUrl: game.coverUrl),
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
        _NamedListSection(title: 'DESARROLLADORES', values: game.developers),
        _NamedListSection(title: 'PUBLISHERS', values: game.publishers),
        _NamedListSection(title: 'TIENDAS', values: game.stores),
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
            children: [for (final tag in game.tags) _TagChip(label: tag)],
          ),
        ],
      ],
    );
  }
}

class _YoutubeTrailerCard extends StatelessWidget {
  const _YoutubeTrailerCard({required this.gameName, required this.coverUrl});

  final String gameName;
  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => openInAppWeb(
            context,
            _youtubeTrailerUrl(gameName),
            title: 'Tráiler',
          ),
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
                      placeholder: (_, _) =>
                          ColoredBox(color: AppColors.surfaceHigh),
                      errorWidget: (_, _, _) =>
                          ColoredBox(color: AppColors.surfaceHigh),
                    )
                  else
                    ColoredBox(color: AppColors.surfaceHigh),
                  const ColoredBox(color: Color(0x99000000)),
                  Center(
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
          'Tráiler oficial en YouTube, dentro de la app.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceMuted),
        ),
      ],
    );
  }
}

String _youtubeTrailerUrl(String gameName) {
  final query = Uri.encodeQueryComponent('$gameName official trailer');
  return 'https://www.youtube.com/results?search_query=$query';
}

bool _hasText(String? value) {
  return value != null && value.trim().isNotEmpty;
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
  const _NamedListSection({required this.title, required this.values});

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
      onPressed: () => openInAppWeb(context, url, title: 'Sitio oficial'),
      icon: const Icon(Icons.public_rounded),
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
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: AppColors.onSurfaceMuted),
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
                      placeholder: (_, _) =>
                          ColoredBox(color: AppColors.surfaceHigh),
                      errorWidget: (_, _, _) =>
                          ColoredBox(color: AppColors.surface),
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
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, animation, _) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: fade,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1).animate(fade),
              child: _ScreenshotLightbox(urls: urls, initialIndex: index),
            ),
          );
        },
      ),
    );
  }
}

class _ContentReveal extends StatefulWidget {
  const _ContentReveal({required this.child});

  final Widget child;

  @override
  State<_ContentReveal> createState() => _ContentRevealState();
}

class _ContentRevealState extends State<_ContentReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 760),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.12, 1, curve: Curves.easeOutCubic),
  );

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.035),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuint));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _ScreenshotLightbox extends StatefulWidget {
  const _ScreenshotLightbox({required this.urls, required this.initialIndex});

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
                      placeholder: (_, _) => Center(
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

class _HeroHeader extends StatefulWidget {
  const _HeroHeader({required this.game, required this.heroTag});

  final Game game;
  final String heroTag;

  @override
  State<_HeroHeader> createState() => _HeroHeaderState();
}

class _HeroHeaderState extends State<_HeroHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
  )..forward();

  late final Animation<double> _overlay = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.28, 1, curve: Curves.easeOutCubic),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GameCoverHero(
            tag: widget.heroTag,
            child: Material(
              color: AppColors.surfaceHigh,
              child: _CoverImage(url: widget.game.coverUrl),
            ),
          ),
          FadeTransition(
            opacity: _overlay,
            child: const DecoratedBox(
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
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: FadeTransition(
                opacity: _overlay,
                child: IconButton(
                  tooltip: 'Volver',
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: AppColors.onSurface,
                ),
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

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.gameId});

  final String gameId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, state) {
        final entry = state.entryFor(gameId);
        final canFavorite = entry?.canBeFavorite ?? false;
        final isFavorite = entry?.isFavorite == true && canFavorite;

        return IconButton(
          tooltip: canFavorite
              ? (isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos')
              : 'Completa el juego para marcarlo como favorito',
          onPressed: () {
            if (!canFavorite) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Debes completar el juego para agregarlo a favoritos',
                  ),
                ),
              );
              return;
            }
            context.read<LibraryCubit>().setFavorite(
              gameId: gameId,
              isFavorite: !isFavorite,
            );
          },
          icon: Icon(
            isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_outline_rounded,
            color: canFavorite
                ? (isFavorite ? AppColors.accent : AppColors.onSurface)
                : AppColors.onSurfaceMuted.withValues(alpha: 0.45),
          ),
        );
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
                tooltip: selected == action.status
                    ? 'Quitar de ${action.status.label}'
                    : action.status.label,
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

class _DealBanner extends StatelessWidget {
  const _DealBanner({required this.state});

  static const Color _green = Color(0xFF4ADE80);
  static const Color _greenSurface = Color(0xFF163323);

  final GameDetailsState state;

  @override
  Widget build(BuildContext context) {
    if (state.loadingDeal && state.deal == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: DealPriceTag(label: null, loading: true),
        ),
      );
    }

    final deal = state.deal;
    if (deal == null || deal.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openDeal(context, deal),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: _greenSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _green.withValues(alpha: 0.45)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_offer_rounded,
                    color: _green,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Oferta: \$${deal.cheapestPrice}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: _green,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          deal.openableOffers.length > 1
                              ? '${deal.detailsSubtitle} · Toca para elegir tienda'
                              : '${deal.detailsSubtitle} · Toca para ir a la oferta',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: _green.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.open_in_new_rounded,
                    color: _green,
                    size: 18,
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

void _openDeal(BuildContext context, GameDeal deal) {
  final offers = deal.openableOffers;
  if (offers.isEmpty) {
    return;
  }
  if (offers.length == 1) {
    openInAppWeb(context, offers.first.url, title: offers.first.storeName);
    return;
  }
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Elige la tienda',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Hay ${offers.length} ofertas. Toca una para ir al descuento.',
                style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.5,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: offers.length,
                  separatorBuilder: (_, _) => Divider(color: AppColors.outline),
                  itemBuilder: (context, index) {
                    final offer = offers[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.storefront_rounded,
                        color: Color(0xFF4ADE80),
                      ),
                      title: Text(offer.storeName),
                      subtitle: Text('Oferta: \$${offer.price}'),
                      trailing: const Icon(Icons.open_in_new_rounded),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        openInAppWeb(
                          context,
                          offer.url,
                          title: offer.storeName,
                        );
                      },
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

        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _openSheet(context, entry),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  entry.priceAlerts
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_outlined,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    entry.priceAlerts ? 'Alerta activa' : 'Notificar oferta',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openSheet(BuildContext context, LibraryEntry entry) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
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
    return SafeArea(
      child: SingleChildScrollView(
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
      ),
    );
  }
}

class _PlatformRow extends StatelessWidget {
  const _PlatformRow({required this.slugs, required this.names});

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
        _MetaChip(icon: Icons.schedule_outlined, label: '${game.playtime} h'),
      if (_hasText(game.esrbRating))
        _MetaChip(icon: Icons.shield_outlined, label: game.esrbRating!),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (items.isNotEmpty) Wrap(spacing: 8, runSpacing: 8, children: items),
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
  const _MetaChip({required this.icon, required this.label});

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
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppColors.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}
