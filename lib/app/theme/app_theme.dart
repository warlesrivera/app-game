import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_palette.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static SystemUiOverlayStyle systemUiFor(AppPalette palette) {
    final darkIcons = !palette.isDark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: darkIcons ? Brightness.dark : Brightness.light,
      statusBarBrightness: palette.isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: palette.background,
      systemNavigationBarIconBrightness: darkIcons
          ? Brightness.dark
          : Brightness.light,
    );
  }

  static SystemUiOverlayStyle get systemUi => systemUiFor(AppColors.palette);

  static ThemeData get dark => from(AppPalette.dark(AccentCatalog.gold));

  static ThemeData from(AppPalette palette) {
    final colorScheme = ColorScheme(
      brightness: palette.brightness,
      primary: palette.accent,
      onPrimary: palette.onAccent,
      secondary: palette.accent,
      onSecondary: palette.onAccent,
      surface: palette.surface,
      onSurface: palette.onSurface,
      error: palette.error,
      onError: palette.onSurface,
      outline: palette.outline,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: palette.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
    );

    return base.copyWith(
      textTheme: AppTypography.textTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: palette.onSurface,
        systemOverlayStyle: systemUiFor(palette),
      ),
      dividerColor: palette.outline,
      tabBarTheme: TabBarThemeData(
        indicatorColor: palette.accent,
        labelColor: palette.accent,
        unselectedLabelColor: palette.onSurfaceMuted,
        dividerColor: palette.outline,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceHigh,
        labelStyle: TextStyle(color: palette.onSurfaceMuted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.accent),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.error),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.accent,
          foregroundColor: palette.onAccent,
          disabledBackgroundColor: palette.surfaceHigh,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.surface,
        selectedItemColor: palette.accent,
        unselectedItemColor: palette.onSurfaceMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.onSurface,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: palette.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
