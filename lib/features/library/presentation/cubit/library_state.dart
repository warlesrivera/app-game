import 'package:equatable/equatable.dart';

import '../../../prices/domain/models/game_deal.dart';
import '../../domain/models/game_taste.dart';
import '../../domain/models/library_entry.dart';
import '../../domain/models/library_game.dart';
import '../../domain/models/library_status.dart';

sealed class LibraryState extends Equatable {
  const LibraryState();

  LibraryFilter get filter => LibraryFilter.all;
  LibraryLayout get layout => LibraryLayout.grid;
  List<LibraryEntry> get entries => const [];
  LibraryStats get stats => const LibraryStats.empty();
  List<LibraryGame> get favoriteGames => const [];
  List<MapEntry<String, int>> get topGenres => const [];
  LibraryEntry? entryFor(String gameId) => null;
  LibraryGame? favoriteAtRank(int rank) => null;

  @override
  List<Object?> get props => [];
}

final class LibraryInitial extends LibraryState {
  const LibraryInitial();
}

final class LibraryLoading extends LibraryState {
  const LibraryLoading({
    this.filter = LibraryFilter.all,
    this.layout = LibraryLayout.grid,
  });

  @override
  final LibraryFilter filter;
  @override
  final LibraryLayout layout;

  @override
  List<Object?> get props => [filter, layout];
}

final class LibraryLoaded extends LibraryState {
  const LibraryLoaded({
    required this.entries,
    required this.games,
    required this.filter,
    this.layout = LibraryLayout.grid,
    this.deals = const {},
    this.loadingDealIds = const {},
  });

  @override
  final List<LibraryEntry> entries;
  final List<LibraryGame> games;
  @override
  final LibraryFilter filter;
  @override
  final LibraryLayout layout;
  final Map<String, GameDeal?> deals;
  final Set<String> loadingDealIds;

  GameDeal? dealFor(String gameId) => deals[gameId];

  bool isDealLoading(String gameId) => loadingDealIds.contains(gameId);

  LibraryLoaded copyWith({
    List<LibraryEntry>? entries,
    List<LibraryGame>? games,
    LibraryFilter? filter,
    LibraryLayout? layout,
    Map<String, GameDeal?>? deals,
    Set<String>? loadingDealIds,
  }) {
    return LibraryLoaded(
      entries: entries ?? this.entries,
      games: games ?? this.games,
      filter: filter ?? this.filter,
      layout: layout ?? this.layout,
      deals: deals ?? this.deals,
      loadingDealIds: loadingDealIds ?? this.loadingDealIds,
    );
  }

  @override
  LibraryStats get stats => LibraryStats.fromEntries(entries);

  List<LibraryGame> get visibleGames => gamesFor(filter);

  List<LibraryGame> gamesFor(LibraryFilter view) {
    return games.where((item) {
      if (view == LibraryFilter.owned) {
        return item.entry.owned;
      }
      return view.matches(item.entry.status);
    }).toList();
  }

  @override
  List<LibraryGame> get favoriteGames {
    return [
      for (final item in games)
        if (item.entry.isFavorite && item.entry.canBeFavorite) item,
    ]..sort((a, b) {
      final rankA = a.entry.favoriteRank ?? 9999;
      final rankB = b.entry.favoriteRank ?? 9999;
      if (rankA != rankB) {
        return rankA.compareTo(rankB);
      }
      return a.game.name.compareTo(b.game.name);
    });
  }

  @override
  LibraryGame? favoriteAtRank(int rank) {
    for (final item in favoriteGames) {
      if (item.entry.favoriteRank == rank) {
        return item;
      }
    }
    return null;
  }

  @override
  List<MapEntry<String, int>> get topGenres {
    final counts = <String, int>{};
    for (final item in games) {
      if (item.entry.status == LibraryStatus.wishlist) {
        continue;
      }
      for (final genre in item.game.genres) {
        if (genre.trim().isEmpty) {
          continue;
        }
        var weight = item.entry.status == LibraryStatus.wishlist ? 0 : 1;
        if (item.entry.taste == GameTaste.liked) {
          weight += 2;
        } else if (item.entry.taste == GameTaste.disliked) {
          weight = 0;
        }
        if (weight == 0) {
          continue;
        }
        counts[genre] = (counts[genre] ?? 0) + weight;
      }
    }
    final ranked = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return ranked.take(3).toList();
  }

  @override
  LibraryEntry? entryFor(String gameId) {
    for (final entry in entries) {
      if (entry.gameId == gameId) {
        return entry;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [
    entries,
    games,
    filter,
    layout,
    deals,
    loadingDealIds,
  ];
}

final class LibraryError extends LibraryState {
  const LibraryError(
    this.message, {
    this.filter = LibraryFilter.all,
    this.layout = LibraryLayout.grid,
  });

  final String message;
  @override
  final LibraryFilter filter;
  @override
  final LibraryLayout layout;

  @override
  List<Object?> get props => [message, filter, layout];
}
