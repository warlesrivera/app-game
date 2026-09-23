import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'page_curl_math.dart';

/// Revela [child] (página nueva) conforme la hoja superior se pelá.
///
/// La ruta anterior se ve debajo porque el [PageRoute] es `opaque: false`.
class PageCurlTransition extends StatelessWidget {
  const PageCurlTransition({
    super.key,
    required this.progress,
    required this.child,
    this.pointer,
  });

  final Animation<double> progress;
  final Widget child;
  final Offset? pointer;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return FadeTransition(opacity: progress, child: child);
    }

    return AnimatedBuilder(
      animation: progress,
      child: child,
      builder: (context, cached) {
        return PageCurlLayer(
          progress: progress.value,
          pointer: pointer,
          back: cached!,
        );
      },
    );
  }
}

/// Capa de page curl. [back] es la hoja que se revela.
/// Si se pasa [front], esa hoja se recorta y permanece sobre la nueva.
class PageCurlLayer extends StatelessWidget {
  const PageCurlLayer({
    super.key,
    required this.progress,
    required this.back,
    this.front,
    this.pointer,
    this.origin = PageCurlOrigin.bottomRight,
  });

  final double progress;
  final Widget back;
  final Widget? front;
  final Offset? pointer;
  final PageCurlOrigin origin;

  @override
  Widget build(BuildContext context) {
    final t = progress.clamp(0.0, 1.0);
    if (t <= 0) {
      return front ?? const SizedBox.expand();
    }
    if (t >= 1 && front == null) {
      return back;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final geometry = PageCurlGeometry.resolve(
          size,
          t,
          pointer: pointer,
          origin: origin,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            if (front == null) const SizedBox.expand() else front!,
            if (geometry == null)
              t > 0.5 ? back : const SizedBox.shrink()
            else ...[
              ClipPath(
                clipper: _CurlClipper(geometry.revealedPath()),
                child: RepaintBoundary(child: back),
              ),
              if (front != null)
                ClipPath(
                  clipper: _CurlClipper(geometry.remainingPath()),
                  child: RepaintBoundary(child: front),
                ),
              IgnorePointer(
                child: CustomPaint(
                  painter: PageCurlPainter(geometry: geometry),
                  size: size,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Arrastre desde la esquina inferior derecha. Completa o cancela con física.
class PageCurlInteractive extends StatefulWidget {
  const PageCurlInteractive({
    super.key,
    required this.front,
    required this.back,
    this.onCompleted,
  });

  final Widget front;
  final Widget back;
  final VoidCallback? onCompleted;

  @override
  State<PageCurlInteractive> createState() => _PageCurlInteractiveState();
}

class _PageCurlInteractiveState extends State<PageCurlInteractive>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Offset? _pointer;
  var _dragging = false;
  var _origin = PageCurlOrigin.bottomRight;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this);
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  PageCurlOrigin? _originAt(Size size, Offset local) {
    final zone = (size.shortestSide * 0.22).clamp(72.0, 140.0);
    if (local.dy < size.height - zone) {
      return null;
    }
    if (local.dx >= size.width - zone) {
      return PageCurlOrigin.bottomRight;
    }
    if (local.dx <= zone) {
      return PageCurlOrigin.bottomLeft;
    }
    return null;
  }

  void _settle({required bool complete, required double velocity}) {
    final target = complete ? 1.0 : 0.0;
    final distance = (target - _controller.value).abs();
    final duration = Duration(
      milliseconds: (420 + distance * 260 - velocity.abs() * 0.04)
          .clamp(240, 720)
          .round(),
    );
    _pointer = null;
    _controller
        .animateTo(
          target,
          duration: duration,
          curve: complete ? Curves.easeInCubic : Curves.easeOutCubic,
        )
        .whenComplete(() {
          if (complete && mounted) {
            widget.onCompleted?.call();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) {
            final origin = _originAt(size, details.localPosition);
            if (origin == null) {
              return;
            }
            _dragging = true;
            _origin = origin;
            _controller.stop();
            _pointer = details.localPosition;
            _controller.value = PageCurlGeometry.progressFromPointer(
              size,
              details.localPosition,
              origin: _origin,
            );
          },
          onPanUpdate: (details) {
            if (!_dragging) {
              return;
            }
            _pointer = details.localPosition;
            _controller.value = PageCurlGeometry.progressFromPointer(
              size,
              details.localPosition,
              origin: _origin,
            );
          },
          onPanEnd: (details) {
            if (!_dragging) {
              return;
            }
            _dragging = false;
            final vx = details.velocity.pixelsPerSecond.dx;
            final flung = _origin == PageCurlOrigin.bottomRight
                ? vx < -700
                : vx > 700;
            final complete = _controller.value > 0.28 || flung;
            _settle(complete: complete, velocity: vx);
          },
          onPanCancel: () {
            if (!_dragging) {
              return;
            }
            _dragging = false;
            _settle(complete: false, velocity: 0);
          },
          child: SizedBox.expand(
            child: PageCurlLayer(
              progress: _controller.value.clamp(0.0, 1.0),
              pointer: _dragging ? _pointer : null,
              origin: _origin,
              front: widget.front,
              back: widget.back,
            ),
          ),
        );
      },
    );
  }
}

class _CurlClipper extends CustomClipper<Path> {
  const _CurlClipper(this.path);

  final Path path;

  @override
  Path getClip(Size size) => path;

  @override
  bool shouldReclip(covariant _CurlClipper oldClipper) =>
      oldClipper.path != path;
}

class PageCurlPainter extends CustomPainter {
  const PageCurlPainter({required this.geometry});

  final PageCurlGeometry geometry;

  @override
  void paint(Canvas canvas, Size size) {
    final flap = geometry.flapPath();
    if (flap.getBounds().isEmpty) {
      return;
    }

    final lift = (1 - (geometry.progress - 0.5).abs() * 2).clamp(0.15, 1.0);
    canvas.drawShadow(flap, const Color(0xCC000000), 10 + lift * 18, false);

    final paper = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: [
          Color.lerp(AppColors.surfaceHigh, Colors.white, 0.18)!,
          AppColors.surface,
          Color.lerp(AppColors.surface, Colors.black, 0.22)!,
        ],
        stops: const [0, 0.45, 1],
      ).createShader(flap.getBounds());
    canvas.drawPath(flap, paper);

    final crease = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.28 * lift),
              Colors.black.withValues(alpha: 0.22),
              Colors.white.withValues(alpha: 0.08),
            ],
          ).createShader(
            Rect.fromCenter(
              center: geometry.mid,
              width: 28,
              height: size.height,
            ),
          );
    if (geometry.edgeHits.length >= 2) {
      canvas.drawLine(
        geometry.edgeHits.first,
        geometry.edgeHits.last,
        Paint()
          ..shader = crease.shader
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawLine(
        geometry.edgeHits.first,
        geometry.edgeHits.last,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35 * lift)
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round,
      );
    }

    final shade = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.black.withValues(alpha: 0.18 * lift),
          Colors.transparent,
        ],
      ).createShader(flap.getBounds());
    canvas.drawPath(flap, shade);
  }

  @override
  bool shouldRepaint(covariant PageCurlPainter oldDelegate) {
    return oldDelegate.geometry.progress != geometry.progress ||
        oldDelegate.geometry.pointer != geometry.pointer;
  }
}
