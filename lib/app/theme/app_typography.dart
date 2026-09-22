import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static TextTheme textTheme(TextTheme base) {
    final outfit = GoogleFonts.outfitTextTheme(
      base,
    ).apply(bodyColor: AppColors.onSurface, displayColor: AppColors.onSurface);

    return outfit.copyWith(
      displayLarge: outfit.displayLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.6,
        height: 1.05,
      ),
      displayMedium: outfit.displayMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
        height: 1.08,
      ),
      displaySmall: outfit.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 2.4,
        height: 1.1,
      ),
      headlineMedium: outfit.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      titleLarge: outfit.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: outfit.bodyLarge?.copyWith(
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: AppColors.onSurfaceMuted,
      ),
      bodyMedium: outfit.bodyMedium?.copyWith(
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: AppColors.onSurfaceMuted,
      ),
      labelLarge: outfit.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
      ),
    );
  }
}
