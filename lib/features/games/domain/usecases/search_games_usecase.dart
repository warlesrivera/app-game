import '../models/game.dart';
import '../repositories/game_repository.dart';

class SearchGamesUseCase {
  const SearchGamesUseCase(this._repository);

  final GameRepository _repository;

  Future<List<Game>> call(String query) {
    return _repository.searchGames(query);
  }
}
