import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.surface,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GAMEVAULT',
                style: textTheme.displaySmall,
              ),
              const SizedBox(height: 16),
              const ColoredBox(
                color: AppColors.accent,
                child: SizedBox(width: 48, height: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
