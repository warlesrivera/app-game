import '../models/game.dart';
import '../models/game_guide.dart';

abstract interface class GameGuideRepository {
  Future<GameGuide> getGuide(Game game);
}
