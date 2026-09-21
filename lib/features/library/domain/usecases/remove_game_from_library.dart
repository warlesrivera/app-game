import '../repositories/library_repository.dart';

class RemoveGameFromLibrary {
  const RemoveGameFromLibrary(this._repository);

  final LibraryRepository _repository;

  Future<void> call(String gameId) => _repository.removeGame(gameId);
}
