import '../models/game_video.dart';
import '../repositories/game_repository.dart';

class GetGameVideos {
  const GetGameVideos(this._repository);

  final GameRepository _repository;

  Future<List<GameVideo>> call(int id) => _repository.getGameVideos(id);
}
