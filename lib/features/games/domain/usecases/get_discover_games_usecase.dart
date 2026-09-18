import '../models/game.dart';
import '../repositories/game_repository.dart';

class GetDiscoverGamesUseCase {
  const GetDiscoverGamesUseCase(this._repository);

  final GameRepository _repository;

  Future<List<Game>> call({int page = 1}) {
    return _repository.getDiscoverGames(page: page);
  }
}
