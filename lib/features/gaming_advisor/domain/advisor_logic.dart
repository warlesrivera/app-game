import '../../library/domain/models/library_game.dart';
import '../../library/domain/models/library_status.dart';
import 'models/gaming_models.dart';

abstract final class LocalQuestionResolver {
  static String? resolve({
    required String question,
    required List<LibraryGame> library,
    required GamingProfile profile,
  }) {
    final folded = _fold(question);
    if (folded.contains('recom') ||
        folded.contains('compar') ||
        folded.contains('gustaria') ||
        folded.contains('por que') ||
        folded.contains('deberia')) {
      return null;
    }
    if (folded.contains('cuantos') || folded.contains('cuantas')) {
      final completed = library
          .where((item) => item.entry.status == LibraryStatus.completed)
          .length;
      final wishlist = library
          .where((item) => item.entry.status == LibraryStatus.wishlist)
          .length;
      if (folded.contains('complet')) {
        return 'Tienes $completed juegos completados.';
      }
      if (folded.contains('wishlist') || folded.contains('dese')) {
        return 'Tienes $wishlist juegos en wishlist.';
      }
      return 'En tu biblioteca hay ${library.length} juegos.';
    }
    if (folded.contains('estoy jugando') || folded.contains('juego actual')) {
      final current = _current(library, profile);
      if (current == null) {
        return 'No tienes un juego marcado como actual.';
      }
      return 'Estás jugando ${current.game.name}.';
    }
    if (folded.contains('cuando sale')) {
      final match = _named(library, folded);
      final date = match?.game.releaseDate;
      if (match == null || date == null) {
        return null;
      }
      return '${match.game.name} está fechado el ${date.day}/${date.month}/${date.year}.';
    }
    if (folded.contains('ya termine') || folded.contains('lo complete')) {
      final match = _named(library, folded) ?? _current(library, profile);
      if (match == null) {
        return 'Ese juego no está en tu biblioteca.';
      }
      if (match.entry.status == LibraryStatus.completed) {
        return 'Sí: ${match.game.name} está completado.';
      }
      return '${match.game.name} está como ${match.entry.status.label}.';
    }
    return null;
  }

  static String _fold(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n');
  }

  static LibraryGame? _current(List<LibraryGame> library, GamingProfile profile) {
    for (final item in library) {
      if (item.game.id == profile.currentGameId) {
        return item;
      }
    }
    for (final item in library) {
      if (item.entry.status == LibraryStatus.playing) {
        return item;
      }
    }
    return null;
  }

  static LibraryGame? _named(List<LibraryGame> library, String folded) {
    for (final item in library) {
      if (folded.contains(_fold(item.game.name))) {
        return item;
      }
    }
    return null;
  }
}

abstract final class GamingViews {
  static List<UpcomingRelease> upcoming(List<LibraryGame> library) {
    final now = DateTime.now();
    final items = [
      for (final item in library)
        if (item.entry.status == LibraryStatus.wishlist ||
            (item.game.releaseDate != null && item.game.releaseDate!.isAfter(now)))
          UpcomingRelease(
            gameId: item.game.id,
            title: item.game.name,
            releaseDate: item.game.releaseDate,
            platforms: item.game.platforms,
            status: item.entry.status.label,
            coverUrl: item.game.coverUrl,
          ),
    ]..sort((a, b) {
      final left = a.releaseDate ?? DateTime(9999);
      final right = b.releaseDate ?? DateTime(9999);
      return left.compareTo(right);
    });
    return items;
  }

  static List<TimelineStop> timeline(List<LibraryGame> library) {
    final stops = <TimelineStop>[];
    void add(LibraryStatus status, String lane) {
      final laneItems = [
        for (final item in library)
          if (item.entry.status == status) item,
      ]..sort((a, b) {
        final left = a.entry.updatedAt ?? DateTime(1970);
        final right = b.entry.updatedAt ?? DateTime(1970);
        return left.compareTo(right);
      });
      for (final item in laneItems) {
        stops.add(
          TimelineStop(
            gameId: item.game.id,
            title: item.game.name,
            lane: lane,
            coverUrl: item.game.coverUrl,
            when: item.entry.updatedAt ?? item.game.releaseDate,
          ),
        );
      }
    }

    add(LibraryStatus.completed, 'Completados');
    add(LibraryStatus.playing, 'Jugando');
    add(LibraryStatus.wishlist, 'Próximos');
    return stops;
  }
}
