import 'package:flutter/material.dart';

class AppPalette {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.accent,
    required this.onAccent,
    required this.outline,
    required this.error,
    required this.glass,
    required this.brightness,
  });

  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color onSurface;
  final Color onSurfaceMuted;
  final Color accent;
  final Color onAccent;
  final Color outline;
  final Color error;
  final Color glass;
  final Brightness brightness;

  bool get isDark => brightness == Brightness.dark;

  static Color contrastOn(Color color) {
    return color.computeLuminance() > 0.55
        ? const Color(0xFF16141A)
        : const Color(0xFFF4F1EA);
  }

  factory AppPalette.dark(Color accent) {
    return AppPalette(
      background: const Color(0xFF07080B),
      surface: const Color(0xFF12141A),
      surfaceHigh: const Color(0xFF1A1D26),
      onSurface: const Color(0xFFF4F1EA),
      onSurfaceMuted: const Color(0xFF9B9BA6),
      accent: accent,
      onAccent: contrastOn(accent),
      outline: const Color(0x1AFFFFFF),
      error: const Color(0xFFD97A7A),
      glass: const Color(0x14FFFFFF),
      brightness: Brightness.dark,
    );
  }

  factory AppPalette.light(Color accent) {
    return AppPalette(
      background: const Color(0xFFF6F3EE),
      surface: const Color(0xFFFFFFFF),
      surfaceHigh: const Color(0xFFEFEAE3),
      onSurface: const Color(0xFF16141A),
      onSurfaceMuted: const Color(0xFF6B6770),
      accent: accent,
      onAccent: contrastOn(accent),
      outline: const Color(0x1A000000),
      error: const Color(0xFFB3261E),
      glass: const Color(0x14000000),
      brightness: Brightness.light,
    );
  }
}

class AccentPreset {
  const AccentPreset({
    required this.id,
    required this.label,
    required this.color,
  });

  final String id;
  final String label;
  final Color color;
}

abstract final class AccentCatalog {
  static const gold = Color(0xFFC4A574);
  static const customId = 'custom';

  static const presets = [
    AccentPreset(id: 'gold', label: 'Bóveda', color: gold),
    AccentPreset(id: 'aubergine', label: 'Aubergine', color: Color(0xFF4A154B)),
    AccentPreset(id: 'ocean', label: 'Océano', color: Color(0xFF38BDF8)),
    AccentPreset(id: 'forest', label: 'Bosque', color: Color(0xFF22C55E)),
    AccentPreset(id: 'crimson', label: 'Carmesí', color: Color(0xFFE11D48)),
    AccentPreset(id: 'violet', label: 'Violeta', color: Color(0xFF8B5CF6)),
    AccentPreset(id: 'amber', label: 'Ámbar', color: Color(0xFFF59E0B)),
    AccentPreset(id: 'slate', label: 'Pizarra', color: Color(0xFF64748B)),
  ];

  static const extras = [
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFF3B82F6),
    Color(0xFF84CC16),
    Color(0xFFF97316),
    Color(0xFFA855F7),
    Color(0xFF06B6D4),
    Color(0xFFEF4444),
    Color(0xFF10B981),
    Color(0xFFEAB308),
    Color(0xFF6366F1),
    Color(0xFFD946EF),
  ];

  static AccentPreset? byId(String id) {
    for (final preset in presets) {
      if (preset.id == id) {
        return preset;
      }
    }
    return null;
  }
}
