import 'package:equatable/equatable.dart';

import '../../domain/models/library_entry.dart';
import '../../domain/models/library_game.dart';
import '../../domain/models/library_status.dart';

sealed class LibraryState extends Equatable {
  const LibraryState();

  LibraryFilter get filter => LibraryFilter.all;
  List<LibraryEntry> get entries => const [];
  LibraryStats get stats => const LibraryStats.empty();
  LibraryEntry? entryFor(String gameId) => null;

  @override
  List<Object?> get props => [];
}

final class LibraryInitial extends LibraryState {
  const LibraryInitial();
}

final class LibraryLoading extends LibraryState {
  const LibraryLoading({this.filter = LibraryFilter.all});

  @override
  final LibraryFilter filter;

  @override
  List<Object?> get props => [filter];
}

final class LibraryLoaded extends LibraryState {
  const LibraryLoaded({
    required this.entries,
    required this.games,
    required this.filter,
  });

  @override
  final List<LibraryEntry> entries;
  final List<LibraryGame> games;
  @override
  final LibraryFilter filter;

  @override
  LibraryStats get stats => LibraryStats.fromEntries(entries);

  List<LibraryGame> get visibleGames {
    return games.where((item) => filter.matches(item.entry.status)).toList();
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
  List<Object?> get props => [entries, games, filter];
}

final class LibraryError extends LibraryState {
  const LibraryError(this.message, {this.filter = LibraryFilter.all});

  final String message;
  @override
  final LibraryFilter filter;

  @override
  List<Object?> get props => [message, filter];
}
