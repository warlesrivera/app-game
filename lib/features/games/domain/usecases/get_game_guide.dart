import '../models/game.dart';
import '../models/game_guide.dart';
import '../repositories/game_guide_repository.dart';

class GetGameGuide {
  const GetGameGuide(this._repository);

  final GameGuideRepository _repository;

  Future<GameGuide> call(Game game) => _repository.getGuide(game);
}
