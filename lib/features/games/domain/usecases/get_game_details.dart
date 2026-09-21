import '../models/game.dart';
import '../repositories/game_repository.dart';

class GetGameDetails {
  const GetGameDetails(this._repository);

  final GameRepository _repository;

  Future<Game> call(int id) => _repository.getGameDetails(id);
}
