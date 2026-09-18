import '../models/library_entry.dart';
import '../repositories/library_repository.dart';

class GetLibraryEntry {
  const GetLibraryEntry(this._repository);

  final LibraryRepository _repository;

  Future<LibraryEntry?> call(String gameId) {
    return _repository.getEntry(gameId);
  }
}
