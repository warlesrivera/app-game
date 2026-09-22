import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/appearance_cubit.dart';

class AppearanceCard extends StatelessWidget {
  const AppearanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<AppearanceCubit, AppearanceState>(
      builder: (context, appearance) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outline),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'APARIENCIA',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.accent,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Como en Slack: sigue el sistema o elige tema y color.',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ModeChip(
                      label: 'Sistema',
                      selected: appearance.mode == ThemeMode.system,
                      onTap: () => context.read<AppearanceCubit>().setMode(
                        ThemeMode.system,
                      ),
                    ),
                    _ModeChip(
                      label: 'Oscuro',
                      selected: appearance.mode == ThemeMode.dark,
                      onTap: () => context.read<AppearanceCubit>().setMode(
                        ThemeMode.dark,
                      ),
                    ),
                    _ModeChip(
                      label: 'Claro',
                      selected: appearance.mode == ThemeMode.light,
                      onTap: () => context.read<AppearanceCubit>().setMode(
                        ThemeMode.light,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Color de acento',
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final preset in AccentCatalog.presets)
                      _ColorDot(
                        color: preset.color,
                        selected:
                            !appearance.isCustom &&
                            appearance.presetId == preset.id,
                        tooltip: preset.label,
                        onTap: () => context.read<AppearanceCubit>().setPreset(
                          preset.id,
                        ),
                      ),
                    _ColorDot(
                      color: appearance.customAccent,
                      selected: appearance.isCustom,
                      tooltip: 'Personalizado',
                      custom: true,
                      onTap: () => _openCustomColors(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openCustomColors(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Color personalizado',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Elige el tono que más te guste. Se guarda en este dispositivo.',
                  style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final color in AccentCatalog.extras)
                      _ColorDot(
                        color: color,
                        selected: false,
                        onTap: () {
                          context.read<AppearanceCubit>().setCustomAccent(
                            color,
                          );
                          Navigator.pop(sheetContext);
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
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
      labelStyle: TextStyle(
        color: selected ? AppColors.onSurface : AppColors.onSurfaceMuted,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(color: selected ? AppColors.accent : AppColors.outline),
      showCheckmark: false,
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
    this.tooltip,
    this.custom = false,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final String? tooltip;
  final bool custom;

  @override
  Widget build(BuildContext context) {
    final dot = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(
              color: selected ? AppColors.onSurface : AppColors.outline,
              width: selected ? 3 : 1,
            ),
          ),
          child: custom
              ? Icon(
                  Icons.colorize_rounded,
                  size: 16,
                  color: AppPalette.contrastOn(color),
                )
              : selected
              ? Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: AppPalette.contrastOn(color),
                )
              : null,
        ),
      ),
    );

    if (tooltip == null) {
      return dot;
    }
    return Tooltip(message: tooltip!, child: dot);
  }
}
