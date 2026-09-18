import '../models/library_entry.dart';
import '../repositories/library_repository.dart';

class WatchLibrary {
  const WatchLibrary(this._repository);

  final LibraryRepository _repository;

  Stream<List<LibraryEntry>> call() => _repository.watchEntries();
}
