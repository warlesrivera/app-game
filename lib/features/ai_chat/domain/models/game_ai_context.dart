import '../../../games/domain/models/game.dart';

class GameAiContext {
  const GameAiContext({
    required this.name,
    this.year,
    this.genres = const [],
    this.platforms = const [],
    this.synopsis,
  });

  factory GameAiContext.fromGame(Game game) {
    return GameAiContext(
      name: game.name,
      year: game.releaseDate?.year,
      genres: game.genres.take(4).toList(),
      platforms: game.platforms.take(4).toList(),
      synopsis: clipText(game.descriptionEs ?? game.description, 220),
    );
  }

  final String name;
  final int? year;
  final List<String> genres;
  final List<String> platforms;
  final String? synopsis;

  String get systemLine {
    final bits = <String>[name];
    if (year != null) {
      bits.add('$year');
    }
    if (genres.isNotEmpty) {
      bits.add(genres.join(', '));
    }
    return bits.join(' · ');
  }

  String? get firstTurnBrief {
    final details = <String>[
      systemLine,
      if (platforms.isNotEmpty) 'Plataformas: ${platforms.join(', ')}',
      if (synopsis != null && synopsis!.isNotEmpty) synopsis!,
    ];
    if (details.length <= 1) {
      return null;
    }
    return details.join('. ');
  }
}

String? clipText(String? value, int max) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  if (trimmed.length <= max) {
    return trimmed;
  }
  return '${trimmed.substring(0, max).trimRight()}…';
}
