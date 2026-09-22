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

  @override
  Future<void> setFavorite({required String gameId, required bool isFavorite}) {
    return _remote.setFavorite(gameId: gameId, isFavorite: isFavorite);
  }

  @override
  Future<void> setFavoriteRank({required String gameId, int? rank}) {
    return _remote.setFavoriteRank(gameId: gameId, rank: rank);
  }

  @override
  Future<void> setFavoriteOrder(List<String> gameIds) {
    return _remote.setFavoriteOrder(gameIds);
  }
}
