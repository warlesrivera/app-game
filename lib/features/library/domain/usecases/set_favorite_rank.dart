import '../repositories/library_repository.dart';

class SetFavoriteRank {
  const SetFavoriteRank(this._repository);

  final LibraryRepository _repository;

  Future<void> call({required String gameId, int? rank}) {
    return _repository.setFavoriteRank(gameId: gameId, rank: rank);
  }

  Future<void> reorder(List<String> gameIds) {
    return _repository.setFavoriteOrder(gameIds);
  }
}
