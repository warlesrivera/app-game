import '../repositories/library_repository.dart';

class SetGameFavorite {
  const SetGameFavorite(this._repository);

  final LibraryRepository _repository;

  Future<void> call({required String gameId, required bool isFavorite}) {
    return _repository.setFavorite(gameId: gameId, isFavorite: isFavorite);
  }
}
