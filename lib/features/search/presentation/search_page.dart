import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/game_card.dart';
import '../../../core/widgets/game_grid.dart';
import '../../games/domain/models/game.dart';
import '../../games/presentation/game_details/game_details_page.dart';
import 'cubit/search_cubit.dart';
import 'cubit/search_state.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'BUSCAR',
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.accent,
                  letterSpacing: 2.2,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: TextField(
                onChanged: context.read<SearchCubit>().onQueryChanged,
                textInputAction: TextInputAction.search,
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurface,
                ),
                cursorColor: AppColors.accent,
                decoration: InputDecoration(
                  hintText: 'Busca un juego',
                  hintStyle: textTheme.bodyLarge,
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.onSurfaceMuted,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceHigh,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.accent),
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  return switch (state) {
                    SearchLoaded(:final games) => _SearchResults(games: games),
                    SearchError(:final message) => _SearchError(
                      message: message,
                    ),
                    SearchLoading() => const _SearchSkeleton(),
                    _ => const _SearchHint(),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchHint extends StatelessWidget {
  const _SearchHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Escribe para descubrir juegos.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.games});

  final List<Game> games;

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) {
      return Center(
        child: Text(
          'No encontramos juegos con esa búsqueda.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return GameGrid(
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        final heroTag = 'search-${game.id}';
        return GameGridCard(
          game: game,
          heroTag: heroTag,
          onTap: () => openGameDetails(
            context,
            game,
            heroTag: heroTag,
          ),
        );
      },
    );
  }
}

class _SearchSkeleton extends StatelessWidget {
  const _SearchSkeleton();

  @override
  Widget build(BuildContext context) {
    return GameGrid(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      itemBuilder: (_, _) => const GameCardSkeleton(fill: true),
    );
  }
}

class _SearchError extends StatelessWidget {
  const _SearchError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(message),
      ),
    );
  }
}
