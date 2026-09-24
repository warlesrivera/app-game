import '../../library/domain/models/library_game.dart';
import '../../library/domain/models/library_status.dart';
import 'models/gaming_models.dart';

abstract final class LocalRecommendationEngine {
  static List<AdvisorRecommendation> rank({
    required String question,
    required GamingProfile profile,
    required List<LibraryGame> library,
    int limit = 5,
  }) {
    final wantsBuy = _has(question, const ['compr', 'wishlist', 'dese']);
    final pool = [
      for (final item in library)
        if (_eligible(item, wantsBuy)) item,
    ];
    final scored = [
      for (final item in pool) MapEntry(item, _score(item, profile, question)),
    ]..sort((a, b) => b.value.compareTo(a.value));

    return [
      for (final entry in scored.take(limit))
        AdvisorRecommendation(
          gameId: entry.key.game.id,
          name: entry.key.game.name,
          coverUrl: entry.key.game.coverUrl,
          status: entry.key.entry.status.label,
          platforms: entry.key.game.platforms,
          releaseLabel: _release(entry.key),
          reasons: _reasons(entry.key, profile),
          warning: _warning(entry.key, profile),
        ),
    ];
  }

  static bool _eligible(LibraryGame item, bool wantsBuy) {
    final status = item.entry.status;
    if (status == LibraryStatus.abandoned || status == LibraryStatus.completed) {
      return false;
    }
    if (wantsBuy) {
      return status == LibraryStatus.wishlist;
    }
    return status == LibraryStatus.wishlist || status == LibraryStatus.playing;
  }

  static int _score(LibraryGame item, GamingProfile profile, String question) {
    var score = item.entry.status == LibraryStatus.playing ? 4 : 2;
    final genres = item.game.genres.map((genre) => genre.toLowerCase()).toSet();
    if (profile.storyImportance >= 4 && genres.any(_isStory)) {
      score += 3;
    }
    if (profile.combatImportance >= 4 && genres.any(_isAction)) {
      score += 3;
    }
    if (profile.explorationImportance >= 4 && genres.any(_isExplore)) {
      score += 2;
    }
    if (profile.repetitionTolerance <= 2 && genres.any(_isGrind)) {
      score -= 3;
    }
    final folded = question.toLowerCase();
    if (folded.contains(item.game.name.toLowerCase())) {
      score += 6;
    }
    if (item.entry.isFavorite) {
      score += 2;
    }
    return score;
  }

  static List<String> _reasons(LibraryGame item, GamingProfile profile) {
    final reasons = <String>[];
    if (item.entry.status == LibraryStatus.wishlist) {
      reasons.add('Ya está en tu wishlist');
    }
    if (item.entry.status == LibraryStatus.playing) {
      reasons.add('Lo estás jugando ahora');
    }
    if (profile.storyImportance >= 4) {
      reasons.add('Valoras la historia');
    }
    if (profile.combatImportance >= 4) {
      reasons.add('Te importa el combate');
    }
    if (profile.explorationImportance >= 4) {
      reasons.add('Te gusta explorar');
    }
    if (item.entry.isFavorite) {
      reasons.add('Está entre tus favoritos');
    }
    return reasons.take(4).toList();
  }

  static String? _warning(LibraryGame item, GamingProfile profile) {
    final hours = item.game.playtime;
    if (hours != null && hours >= 30 && profile.repetitionTolerance <= 2) {
      return 'Es un juego largo y tiene bastante contenido opcional.';
    }
    if (profile.objectiveClarityImportance >= 4 &&
        item.game.genres.any((genre) => genre.toLowerCase().contains('rpg'))) {
      return 'Los RPG a veces dejan los objetivos poco claros.';
    }
    return null;
  }

  static String? _release(LibraryGame item) {
    final date = item.game.releaseDate;
    if (date == null) {
      return null;
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  static bool _has(String question, List<String> needles) {
    final folded = question.toLowerCase();
    return needles.any(folded.contains);
  }

  static bool _isStory(String genre) =>
      genre.contains('adventure') || genre.contains('rpg') || genre.contains('aventura');

  static bool _isAction(String genre) =>
      genre.contains('action') || genre.contains('shooter') || genre.contains('acci');

  static bool _isExplore(String genre) =>
      genre.contains('adventure') || genre.contains('open');

  static bool _isGrind(String genre) =>
      genre.contains('mmo') || genre.contains('sports');
}
