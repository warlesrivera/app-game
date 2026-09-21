import '../../domain/models/library_entry.dart';
import '../../domain/models/library_status.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/library_remote_datasource.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  const LibraryRepositoryImpl(this._remote);

  final LibraryRemoteDataSource _remote;

  @override
  Stream<List<LibraryEntry>> watchEntries() => _remote.watchEntries();

  @override
  Future<LibraryEntry?> getEntry(String gameId) => _remote.getEntry(gameId);

  @override
  Future<void> setStatus({
    required String gameId,
    required LibraryStatus status,
  }) {
    return _remote.setStatus(gameId: gameId, status: status);
  }

  @override
  Future<void> removeGame(String gameId) {
    return _remote.removeGame(gameId);
  }
}
