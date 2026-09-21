import '../models/catalog_row.dart';
import '../models/game.dart';
import '../repositories/game_repository.dart';

class GetCatalogRowsUseCase {
  const GetCatalogRowsUseCase(this._repository);

  final GameRepository _repository;

  static String _range(DateTime from, DateTime to) {
    String stamp(DateTime date) {
      return '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
    }

    return '${stamp(from)},${stamp(to)}';
  }

  static List<CatalogQuery> queriesFor(DateTime now) {
    final dayShift = now.day % 4;
    final novedadesFrom = now.subtract(const Duration(days: 240));
    final modernFrom = DateTime(now.year - 7, now.month, 1);

    return [
      CatalogQuery(
        id: 'discover',
        title: 'DESCUBRE',
        ordering: '-added',
        page: 1 + dayShift,
      ),
      CatalogQuery(
        id: 'playstation',
        title: 'PLAYSTATION',
        parentPlatforms: 2,
        ordering: '-released',
        dates: _range(modernFrom, now),
        page: 1 + ((dayShift + 1) % 4),
      ),
      CatalogQuery(
        id: 'nintendo',
        title: 'NINTENDO',
        parentPlatforms: 7,
        ordering: '-rating',
        page: 1 + ((dayShift + 2) % 4),
      ),
      CatalogQuery(
        id: 'xbox',
        title: 'XBOX',
        parentPlatforms: 3,
        ordering: '-metacritic',
        page: 1 + ((dayShift + 3) % 4),
      ),
      CatalogQuery(
        id: 'nextgen',
        title: 'ÚLTIMA GENERACIÓN',
        platforms: '187,186',
        ordering: '-added',
        page: 2 + (dayShift % 3),
      ),
      CatalogQuery(
        id: 'novedades',
        title: 'NOVEDADES',
        ordering: '-released',
        dates: _range(novedadesFrom, now),
      ),
      const CatalogQuery(
        id: 'retros',
        title: 'RETROS',
        platforms: '49,79,83,27,15,24,26,43,105,11,9,167,106,80,17',
        ordering: '-rating',
        dates: '1983-01-01,2008-12-31',
      ),
    ];
  }

  Future<List<CatalogRow>> call() async {
    final queries = queriesFor(DateTime.now());
    final rows = await Future.wait(
      queries.map((query) async {
        try {
          final games = await _repository.getCatalog(
            catalogId: query.id,
            parentPlatforms: query.parentPlatforms,
            platforms: query.platforms,
            ordering: query.ordering,
            dates: query.dates,
            page: query.page,
          );
          return CatalogRow(
            id: query.id,
            title: query.title,
            games: games,
          );
        } catch (_) {
          return CatalogRow(
            id: query.id,
            title: query.title,
            games: const [],
          );
        }
      }),
    );

    final visible = _withoutRepeatedGames(rows)
        .where((row) => row.games.isNotEmpty)
        .toList();
    if (visible.isEmpty) {
      throw StateError('No se pudieron cargar los catálogos.');
    }
    return visible;
  }

  List<CatalogRow> _withoutRepeatedGames(List<CatalogRow> rows) {
    final seen = <String>{};
    return [
      for (final row in rows)
        CatalogRow(
          id: row.id,
          title: row.title,
          games: _uniqueEnough(row.games, seen),
        ),
    ];
  }

  List<Game> _uniqueEnough(List<Game> games, Set<String> seen) {
    final unique = <Game>[];
    final fallback = <Game>[];
    for (final game in games) {
      if (seen.add(game.id)) {
        unique.add(game);
      } else {
        fallback.add(game);
      }
    }
    if (unique.length >= 8) {
      return unique;
    }
    return [...unique, ...fallback].take(20).toList();
  }
}
