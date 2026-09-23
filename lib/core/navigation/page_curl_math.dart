import 'dart:math' as math;
import 'dart:ui';

enum PageCurlOrigin { bottomRight, bottomLeft }

/// Geometría de un page curl 2D: la hoja se pela desde una esquina inferior.
///
/// La línea de pliegue es la mediatriz entre la esquina [corner] y el punto
/// de agarre [pointer]. El papel levantado se refleja sobre ese pliegue.
final class PageCurlGeometry {
  const PageCurlGeometry({
    required this.size,
    required this.corner,
    required this.pointer,
    required this.mid,
    required this.normal,
    required this.tangent,
    required this.edgeHits,
    required this.progress,
    required this.origin,
  });

  final Size size;
  final Offset corner;
  final Offset pointer;
  final Offset mid;
  final Offset normal;
  final Offset tangent;
  final List<Offset> edgeHits;
  final double progress;
  final PageCurlOrigin origin;

  static Offset cornerOf(Size size, PageCurlOrigin origin) {
    return origin == PageCurlOrigin.bottomRight
        ? Offset(size.width, size.height)
        : Offset(0, size.height);
  }

  static PageCurlGeometry? resolve(
    Size size,
    double progress, {
    Offset? pointer,
    PageCurlOrigin origin = PageCurlOrigin.bottomRight,
  }) {
    if (size.isEmpty) {
      return null;
    }
    final t = progress.clamp(0.0, 1.0);
    if (t <= 0) {
      return null;
    }

    final corner = cornerOf(size, origin);
    final raw = pointer ?? animatedPointer(size, t, origin: origin);
    final clamped = constrainPointer(size, corner, raw, origin: origin);
    if ((clamped - corner).distance < 6) {
      return null;
    }

    final mid = Offset(
      (clamped.dx + corner.dx) / 2,
      (clamped.dy + corner.dy) / 2,
    );
    final delta = clamped - corner;
    final length = delta.distance;
    if (length < 1) {
      return null;
    }
    final normal = delta / length;
    final tangent = Offset(-normal.dy, normal.dx);
    final hits = intersectRect(size, mid, tangent);
    if (hits.length < 2 && t < 0.98) {
      return null;
    }

    return PageCurlGeometry(
      size: size,
      corner: corner,
      pointer: clamped,
      mid: mid,
      normal: normal,
      tangent: tangent,
      edgeHits: hits,
      progress: t,
      origin: origin,
    );
  }

  /// Recorrido automático de la esquina hacia el lado opuesto.
  static Offset animatedPointer(
    Size size,
    double t, {
    PageCurlOrigin origin = PageCurlOrigin.bottomRight,
  }) {
    final curved = curlEaseInOutCubic(t.clamp(0.0, 1.0));
    if (origin == PageCurlOrigin.bottomLeft) {
      final start = Offset(2, size.height - 2);
      final end = Offset(size.width * 1.42, size.height * 0.18);
      return Offset.lerp(start, end, curved)!;
    }
    final start = Offset(size.width - 2, size.height - 2);
    final end = Offset(-size.width * 0.42, size.height * 0.18);
    return Offset.lerp(start, end, curved)!;
  }

  static Offset constrainPointer(
    Size size,
    Offset corner,
    Offset raw, {
    PageCurlOrigin origin = PageCurlOrigin.bottomRight,
  }) {
    final minY = -size.height * 0.15;
    final maxY = corner.dy - 10;
    if (origin == PageCurlOrigin.bottomLeft) {
      return Offset(
        raw.dx.clamp(corner.dx + 10, size.width * 1.55),
        raw.dy.clamp(minY, maxY),
      );
    }
    return Offset(
      raw.dx.clamp(-size.width * 0.55, corner.dx - 10),
      raw.dy.clamp(minY, maxY),
    );
  }

  /// Progreso 0-1 a partir de un arrastre, usando la diagonal de la hoja.
  static double progressFromPointer(
    Size size,
    Offset pointer, {
    PageCurlOrigin origin = PageCurlOrigin.bottomRight,
  }) {
    final corner = cornerOf(size, origin);
    final travel = (corner - pointer).distance;
    final diagonal = math.sqrt(
      size.width * size.width + size.height * size.height,
    );
    return (travel / (diagonal * 0.72)).clamp(0.0, 1.0);
  }

  bool isOnRevealedSide(Offset point) {
    return (point - mid).dx * normal.dx + (point - mid).dy * normal.dy < 0;
  }

  Offset reflect(Offset point) {
    final toMid = point - mid;
    final dot = toMid.dx * normal.dx + toMid.dy * normal.dy;
    return point - Offset(normal.dx, normal.dy) * (dot * 2);
  }

  Path revealedPath() {
    if (progress >= 0.995) {
      return Path()..addRect(Offset.zero & size);
    }
    return _halfPlanePath(revealed: true);
  }

  Path remainingPath() {
    if (progress >= 0.995) {
      return Path();
    }
    return _halfPlanePath(revealed: false);
  }

  Path flapPath() {
    final source = <Offset>[corner, ...edgeHits];
    final unique = _unique(source);
    if (unique.length < 2) {
      return Path();
    }
    final reflected = [for (final point in unique) reflect(point)];
    final points = _unique([...reflected, ...edgeHits]);
    return _polygon(points);
  }

  Path _halfPlanePath({required bool revealed}) {
    final corners = <Offset>[
      Offset.zero,
      Offset(size.width, 0),
      Offset(size.width, size.height),
      Offset(0, size.height),
    ];
    final kept = <Offset>[
      for (final point in corners)
        if (isOnRevealedSide(point) == revealed) point,
      ...edgeHits,
    ];
    return _polygon(kept);
  }

  static List<Offset> intersectRect(Size size, Offset origin, Offset dir) {
    final hits = <Offset>[];

    void consider(Offset point) {
      if (point.dx < -0.6 ||
          point.dx > size.width + 0.6 ||
          point.dy < -0.6 ||
          point.dy > size.height + 0.6) {
        return;
      }
      for (final existing in hits) {
        if ((existing - point).distance < 1.2) {
          return;
        }
      }
      hits.add(point);
    }

    if (dir.dx.abs() > 1e-6) {
      final tLeft = (0 - origin.dx) / dir.dx;
      consider(Offset(0, origin.dy + dir.dy * tLeft));
      final tRight = (size.width - origin.dx) / dir.dx;
      consider(Offset(size.width, origin.dy + dir.dy * tRight));
    }
    if (dir.dy.abs() > 1e-6) {
      final tTop = (0 - origin.dy) / dir.dy;
      consider(Offset(origin.dx + dir.dx * tTop, 0));
      final tBottom = (size.height - origin.dy) / dir.dy;
      consider(Offset(origin.dx + dir.dx * tBottom, size.height));
    }
    return hits;
  }

  static List<Offset> _unique(List<Offset> points) {
    final result = <Offset>[];
    for (final point in points) {
      var skip = false;
      for (final existing in result) {
        if ((existing - point).distance < 1) {
          skip = true;
          break;
        }
      }
      if (!skip) {
        result.add(point);
      }
    }
    return result;
  }

  Path _polygon(List<Offset> points) {
    if (points.length < 3) {
      return Path();
    }
    var cx = 0.0;
    var cy = 0.0;
    for (final point in points) {
      cx += point.dx;
      cy += point.dy;
    }
    cx /= points.length;
    cy /= points.length;
    points.sort((a, b) {
      return math
          .atan2(a.dy - cy, a.dx - cx)
          .compareTo(math.atan2(b.dy - cy, b.dx - cx));
    });
    return Path()
      ..addPolygon(points, true)
      ..close();
  }
}

double curlEaseInOutCubic(double t) {
  return t < 0.5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3) / 2;
}
