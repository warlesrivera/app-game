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
    List<String> liked = const [],
    List<String> disliked = const [],
    List<String> playingNames = const [],
    List<String> completedNames = const [],
    List<String> abandonedNames = const [],
  }) async {
    final raw = await _repository.generatePlayerProfile(
      completed: completed,
      abandoned: abandoned,
      playing: playing,
      favoriteGenre: favoriteGenre,
      topFavorites: topFavorites,
      genreCounts: genreCounts,
      liked: liked,
      disliked: disliked,
      playingNames: playingNames,
      completedNames: completedNames,
      abandonedNames: abandonedNames,
    );
    final parsed = PlayerAnalysis.tryParse(raw, fingerprint: fingerprint);
    if (parsed == null) {
      return null;
    }
    final known = {
      ...topFavorites,
      ...liked,
      ...disliked,
      ...playingNames,
      ...completedNames,
      ...abandonedNames,
    }.map((name) => name.trim().toLowerCase()).where((name) => name.isNotEmpty);
    if (known.contains(parsed.title.trim().toLowerCase())) {
      return PlayerAnalysis(
        title: 'Tu forma de jugar',
        summary: parsed.summary.isNotEmpty ? parsed.summary : parsed.details,
        details: parsed.details,
        fingerprint: fingerprint,
      );
    }
    return parsed;
  }
}
