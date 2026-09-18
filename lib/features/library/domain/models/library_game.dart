import 'package:equatable/equatable.dart';

import '../../../games/domain/models/game.dart';
import 'library_entry.dart';
import 'library_status.dart';

class LibraryGame extends Equatable {
  const LibraryGame({
    required this.game,
    required this.entry,
  });

  final Game game;
  final LibraryEntry entry;

  @override
  List<Object?> get props => [game, entry];
}

class LibraryStats extends Equatable {
  const LibraryStats({
    required this.playing,
    required this.completed,
    required this.wishlist,
    required this.abandoned,
  });

  const LibraryStats.empty()
    : playing = 0,
      completed = 0,
      wishlist = 0,
      abandoned = 0;

  final int playing;
  final int completed;
  final int wishlist;
  final int abandoned;

  int get total => playing + completed + wishlist + abandoned;

  factory LibraryStats.fromEntries(Iterable<LibraryEntry> entries) {
    var playing = 0;
    var completed = 0;
    var wishlist = 0;
    var abandoned = 0;
    for (final entry in entries) {
      switch (entry.status) {
        case LibraryStatus.playing:
          playing += 1;
        case LibraryStatus.completed:
          completed += 1;
        case LibraryStatus.wishlist:
          wishlist += 1;
        case LibraryStatus.abandoned:
          abandoned += 1;
      }
    }
    return LibraryStats(
      playing: playing,
      completed: completed,
      wishlist: wishlist,
      abandoned: abandoned,
    );
  }

  @override
  List<Object?> get props => [playing, completed, wishlist, abandoned];
}
