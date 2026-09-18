import '../models/game.dart';
import '../repositories/game_repository.dart';

class GetGamesByIds {
  const GetGamesByIds(this._repository);

  final GameRepository _repository;

  Future<List<Game>> call(List<String> ids) {
    return _repository.getGamesByIds(ids);
  }
}
