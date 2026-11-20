import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../profile/presentation/cubit/current_console_cubit.dart';
import '../../domain/models/game_taste.dart';
import '../../domain/models/library_status.dart';
import '../../domain/models/ownership.dart';
import '../cubit/library_cubit.dart';
import '../cubit/library_state.dart';
import 'console_picker.dart';

class LibraryCollectionPanel extends StatelessWidget {
  const LibraryCollectionPanel({super.key, required this.gameId});

  final String gameId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, state) {
        final entry = state.entryFor(gameId);
        if (entry == null) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.status == LibraryStatus.abandoned) ...[
              const SizedBox(height: 16),
              Text(
                'Puedes abandonarlo y que igual te haya gustado.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
              const SizedBox(height: 8),
              TasteChoice(
                taste: entry.taste,
                onChanged: (taste) {
                  context.read<LibraryCubit>().setTaste(
                    gameId: gameId,
                    taste: taste,
                  );
                },
              ),
            ],
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ya lo tengo'),
              subtitle: const Text('Consola, físico o tienda digital'),
              value: entry.owned,
              onChanged: (owned) {
                final current = context.read<CurrentConsoleCubit>().state;
                context.read<LibraryCubit>().setOwnership(
                  gameId: gameId,
                  owned: owned,
                  format: owned
                      ? entry.ownershipFormat ?? OwnershipFormat.digital
                      : null,
                  store: owned ? entry.ownershipStore : null,
                  console: owned
                      ? entry.ownershipConsole ?? current
                      : null,
                );
              },
            ),
            if (entry.owned) ...[
              const SizedBox(height: 8),
              Text(
                'Consola',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 8),
              BlocBuilder<CurrentConsoleCubit, String?>(
                builder: (context, current) {
                  return ConsolePicker(
                    selected: entry.ownershipConsole,
                    currentSlug: current,
                    onSelected: (slug) {
                      context.read<LibraryCubit>().setOwnership(
                        gameId: gameId,
                        owned: true,
                        format: entry.ownershipFormat ?? OwnershipFormat.digital,
                        store: entry.ownershipStore,
                        console: slug,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final format in OwnershipFormat.values)
                    ChoiceChip(
                      label: Text(format.label),
                      selected: entry.ownershipFormat == format,
                      onSelected: (_) {
                        context.read<LibraryCubit>().setOwnership(
                          gameId: gameId,
                          owned: true,
                          format: format,
                          store: format == OwnershipFormat.digital
                              ? entry.ownershipStore
                              : null,
                          console: entry.ownershipConsole,
                        );
                      },
                    ),
                ],
              ),
              if (entry.ownershipFormat != OwnershipFormat.physical) ...[
                const SizedBox(height: 12),
                Text(
                  'Tiendas',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final store in OwnershipStore.values)
                      ChoiceChip(
                        label: Text(store.label),
                        selected: entry.ownershipStore == store,
                        onSelected: (_) {
                          context.read<LibraryCubit>().setOwnership(
                            gameId: gameId,
                            owned: true,
                            format: OwnershipFormat.digital,
                            store: store,
                            console: entry.ownershipConsole,
                          );
                        },
                      ),
                  ],
                ),
              ],
            ],
          ],
        );
      },
    );
  }
}

class TasteChoice extends StatelessWidget {
  const TasteChoice({
    super.key,
    required this.taste,
    required this.onChanged,
    this.compact = false,
  });

  final GameTaste? taste;
  final ValueChanged<GameTaste?> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in GameTaste.values)
          ChoiceChip(
            label: Text(compact ? _short(option) : option.label),
            selected: taste == option,
            visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
            avatar: Icon(_icon(option, taste == option), size: 16),
            onSelected: (_) {
              onChanged(taste == option ? null : option);
            },
          ),
      ],
    );
  }

  static String _short(GameTaste taste) => switch (taste) {
    GameTaste.liked => 'Sí',
    GameTaste.disliked => 'No',
  };

  static IconData _icon(GameTaste taste, bool selected) => switch (taste) {
    GameTaste.liked =>
      selected ? Icons.thumb_up_alt_rounded : Icons.thumb_up_alt_outlined,
    GameTaste.disliked =>
      selected ? Icons.thumb_down_alt_rounded : Icons.thumb_down_alt_outlined,
  };
}
