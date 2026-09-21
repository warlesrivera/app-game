import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Mapea slugs de RAWG a logos locales (PNG o SVG).
abstract final class PlatformIconMapper {
  static const String _assetDir = 'assets/icons/platforms';

  /// Extensión exacta de cada slug confirmado. No inferir: los formatos son mixtos.
  static const Map<String, String> _extensionBySlug = {
    'nintendo-64': 'png',
    'nintendo-switch-2': 'png',
    'nintendo-switch': 'svg',
    'playstation': 'svg',
    'playstation2': 'svg',
    'playstation3': 'svg',
    'playstation4': 'svg',
    'playstation5': 'svg',
    'playstationvita': 'svg',
    'psp': 'svg',
    'xbox': 'svg',
  };

  static const Map<String, IconData> _materialBySlug = {
    'pc': Icons.desktop_windows_rounded,
  };

  /// Variantes de RAWG / nombres de lista que apuntan a un slug con asset.
  static const Map<String, String> _aliases = {
    'macos': 'pc',
    'linux': 'pc',
    'steam': 'pc',
    'nintendo 64': 'nintendo-64',
    'n64': 'nintendo-64',
    'nintendo switch': 'nintendo-switch',
    'nintendo switch 2': 'nintendo-switch-2',
    'playstation 1': 'playstation',
    'playstation 2': 'playstation2',
    'playstation 3': 'playstation3',
    'playstation 4': 'playstation4',
    'playstation 5': 'playstation5',
    'ps1': 'playstation',
    'ps2': 'playstation2',
    'ps3': 'playstation3',
    'ps4': 'playstation4',
    'ps5': 'playstation5',
    'ps vita': 'playstationvita',
    'ps-vita': 'playstationvita',
    'psvita': 'playstationvita',
    'playstation vita': 'playstationvita',
    'xbox one': 'xbox',
    'xbox-one': 'xbox',
    'xbox series x': 'xbox',
    'xbox-series-x': 'xbox',
    'xbox series s': 'xbox',
    'xbox-series-s': 'xbox',
    'xbox series s/x': 'xbox',
    'xbox series x/s': 'xbox',
    'xbox 360': 'xbox',
    'xbox360': 'xbox',
    'xbox-old': 'xbox',
  };

  static Widget iconFor(
    String slug, {
    double size = 16,
    Color color = Colors.white,
  }) {
    final key = canonicalSlug(slug);
    final materialIcon = _materialBySlug[key];
    if (materialIcon != null) {
      return Icon(materialIcon, size: size, color: color);
    }

    final extension = _extensionBySlug[key];
    if (extension == null) {
      return Icon(Icons.videogame_asset, size: size, color: color);
    }

    final path = '$_assetDir/$key.$extension';
    if (extension == 'svg') {
      return SvgPicture.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    }

    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
  }

  static Widget row({
    required List<String> slugs,
    List<String> names = const [],
    double size = 16,
    double spacing = 6,
    Color color = Colors.white,
  }) {
    final values = slugs.isNotEmpty ? slugs : names;
    final keys = uniqueSlugs(values);
    if (keys.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < keys.length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          Tooltip(
            message: keys[i] == '_default'
                ? 'Otras'
                : keys[i] == 'pc'
                ? 'PC'
                : keys[i],
            child: SizedBox(
              width: size,
              height: size,
              child: iconFor(keys[i], size: size, color: color),
            ),
          ),
        ],
      ],
    );
  }

  static List<String> uniqueSlugs(Iterable<String> values) {
    final keys = <String>[];
    final seen = <String>{};
    var hasUnknown = false;

    for (final value in values) {
      final key = canonicalSlug(value);
      if (_extensionBySlug.containsKey(key) ||
          _materialBySlug.containsKey(key)) {
        if (seen.add(key)) {
          keys.add(key);
        }
      } else if (value.trim().isNotEmpty) {
        hasUnknown = true;
      }
    }

    if (hasUnknown && seen.add('_default')) {
      keys.add('_default');
    }
    return keys;
  }

  static String canonicalSlug(String raw) {
    final value = raw.trim().toLowerCase();
    if (value.isEmpty) {
      return value;
    }
    if (_extensionBySlug.containsKey(value) ||
        _materialBySlug.containsKey(value)) {
      return value;
    }
    return _aliases[value] ?? value;
  }
}
