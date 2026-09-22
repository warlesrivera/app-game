import '../../../ai_chat/domain/repositories/game_ai_repository.dart';
import '../models/player_analysis.dart';

class GeneratePlayerProfile {
  const GeneratePlayerProfile(this._repository);

  final GameAIRepository _repository;

  Future<PlayerAnalysis?> call({
    required int completed,
    required int abandoned,
    required int playing,
    required String favoriteGenre,
    required List<String> topFavorites,
    required Map<String, int> genreCounts,
    required String fingerprint,
  }) async {
    final raw = await _repository.generatePlayerProfile(
      completed: completed,
      abandoned: abandoned,
      playing: playing,
      favoriteGenre: favoriteGenre,
      topFavorites: topFavorites,
      genreCounts: genreCounts,
    );
    return PlayerAnalysis.tryParse(raw, fingerprint: fingerprint);
  }
}
