import '../models/game_taste.dart';
import '../models/library_entry.dart';
import '../models/library_status.dart';
import '../models/ownership.dart';

abstract interface class LibraryRepository {
  Stream<List<LibraryEntry>> watchEntries();

  Future<LibraryEntry?> getEntry(String gameId);

  Future<void> setStatus({
    required String gameId,
    required LibraryStatus status,
  });

  Future<void> removeGame(String gameId);

  Future<void> setFavorite({required String gameId, required bool isFavorite});

  Future<void> setFavoriteRank({required String gameId, int? rank});

  Future<void> setFavoriteOrder(List<String> gameIds);

  Future<void> setTaste({required String gameId, GameTaste? taste});

  Future<void> setOwnership({
    required String gameId,
    required bool owned,
    OwnershipFormat? format,
    OwnershipStore? store,
    String? console,
  });
}
