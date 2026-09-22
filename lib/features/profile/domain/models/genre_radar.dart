import 'package:equatable/equatable.dart';

import '../../../library/domain/models/library_game.dart';
import '../../../library/domain/models/library_status.dart';

class GenreAxis extends Equatable {
  const GenreAxis({
    required this.label,
    required this.count,
    required this.value,
  });

  final String label;
  final int count;
  final double value;

  @override
  List<Object?> get props => [label, count, value];
}

class GenreRadar extends Equatable {
  const GenreRadar({required this.axes, required this.favoriteGenre});

  const GenreRadar.empty() : axes = const [], favoriteGenre = 'Sin datos';

  static const labels = [
    'Acción',
    'RPG',
    'Aventura',
    'Shooter',
    'Plataformas',
    'Deportes',
  ];

  final List<GenreAxis> axes;
  final String favoriteGenre;

  bool get hasData => axes.any((axis) => axis.count > 0);

  factory GenreRadar.fromLibrary(Iterable<LibraryGame> games) {
    final counts = {for (final label in labels) label: 0};
    for (final item in games) {
      if (item.entry.status != LibraryStatus.playing &&
          item.entry.status != LibraryStatus.completed) {
        continue;
      }
      for (final genre in item.game.genres) {
        final axis = _mapGenre(genre);
        if (axis == null) {
          continue;
        }
        counts[axis] = (counts[axis] ?? 0) + 1;
      }
    }

    final maxCount = counts.values.fold<int>(0, (max, value) {
      return value > max ? value : max;
    });
    final favorite = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return GenreRadar(
      axes: [
        for (final label in labels)
          GenreAxis(
            label: label,
            count: counts[label] ?? 0,
            value: maxCount == 0 ? 0 : (counts[label] ?? 0) / maxCount,
          ),
      ],
      favoriteGenre: (favorite.isEmpty || favorite.first.value == 0)
          ? 'Sin datos'
          : favorite.first.key,
    );
  }

  static String? _mapGenre(String raw) {
    final genre = raw.toLowerCase();
    if (genre.contains('rpg') || genre.contains('role')) {
      return 'RPG';
    }
    if (genre.contains('shooter')) {
      return 'Shooter';
    }
    if (genre.contains('platform')) {
      return 'Plataformas';
    }
    if (genre.contains('sport')) {
      return 'Deportes';
    }
    if (genre.contains('adventure') || genre.contains('aventura')) {
      return 'Aventura';
    }
    if (genre.contains('action') ||
        genre.contains('acción') ||
        genre.contains('fighting') ||
        genre.contains('brawler')) {
      return 'Acción';
    }
    return null;
  }

  @override
  List<Object?> get props => [axes, favoriteGenre];
}
