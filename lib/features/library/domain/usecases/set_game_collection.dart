import '../models/game_taste.dart';
import '../models/ownership.dart';
import '../repositories/library_repository.dart';

class SetGameTaste {
  const SetGameTaste(this._repository);

  final LibraryRepository _repository;

  Future<void> call({required String gameId, GameTaste? taste}) {
    return _repository.setTaste(gameId: gameId, taste: taste);
  }
}

class SetGameOwnership {
  const SetGameOwnership(this._repository);

  final LibraryRepository _repository;

  Future<void> call({
    required String gameId,
    required bool owned,
    OwnershipFormat? format,
    OwnershipStore? store,
    String? console,
  }) {
    return _repository.setOwnership(
      gameId: gameId,
      owned: owned,
      format: format,
      store: store,
      console: console,
    );
  }
}
