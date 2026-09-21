import '../models/library_entry.dart';
import '../models/library_status.dart';

abstract interface class LibraryRepository {
  Stream<List<LibraryEntry>> watchEntries();

  Future<LibraryEntry?> getEntry(String gameId);

  Future<void> setStatus({
    required String gameId,
    required LibraryStatus status,
  });

  Future<void> removeGame(String gameId);
}
