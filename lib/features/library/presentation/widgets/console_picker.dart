import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/platform_icon_mapper.dart';
import '../../domain/models/game_console.dart';

class ConsolePicker extends StatelessWidget {
  const ConsolePicker({
    super.key,
    required this.selected,
    required this.onSelected,
    this.currentSlug,
  });

  final String? selected;
  final String? currentSlug;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final console in GameConsole.all)
          ChoiceChip(
            avatar: PlatformIconMapper.iconFor(
              console.slug,
              size: 16,
              color: AppColors.onSurface,
            ),
            label: Text(
              console.slug == currentSlug
                  ? '${console.label} · actual'
                  : console.label,
            ),
            selected: selected == console.slug,
            onSelected: (_) => onSelected(console.slug),
          ),
      ],
    );
  }
}
