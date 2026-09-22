import 'package:flutter/material.dart';

import 'app_palette.dart';

abstract final class AppColors {
  static AppPalette _palette = AppPalette.dark(AccentCatalog.gold);

  static AppPalette get palette => _palette;

  static void bind(AppPalette palette) {
    _palette = palette;
  }

  static Color get background => _palette.background;
  static Color get surface => _palette.surface;
  static Color get surfaceHigh => _palette.surfaceHigh;
  static Color get onSurface => _palette.onSurface;
  static Color get onSurfaceMuted => _palette.onSurfaceMuted;
  static Color get accent => _palette.accent;
  static Color get onAccent => _palette.onAccent;
  static Color get outline => _palette.outline;
  static Color get error => _palette.error;
  static Color get glass => _palette.glass;
}
