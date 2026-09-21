import '../models/catalog_collection.dart';
import '../models/game.dart';
import '../repositories/game_repository.dart';
import 'get_catalog_rows.dart';

class GetCatalogCollection {
  const GetCatalogCollection(this._repository);

  final GameRepository _repository;

  static const int previewPageSize = 12;

  List<CatalogSectionQuery> queriesFor({
    required String catalogId,
    required String title,
  }) {
    return _queriesFor(catalogId, title);
  }

  Future<List<Game>> loadSection({
    required CatalogSectionQuery query,
    int page = 1,
    int pageSize = previewPageSize,
  }) {
    return _repository.getCatalog(
      catalogId: query.id,
      parentPlatforms: query.parentPlatforms,
      platforms: query.platforms,
      ordering: query.ordering,
      dates: query.dates,
      page: page,
      pageSize: pageSize,
    );
  }

  Future<CatalogCollection> call({
    required String catalogId,
    required String title,
  }) async {
    final queries = _queriesFor(catalogId, title);
    final sections = [
      for (final query in queries)
        CatalogSection(
          id: query.id,
          title: query.title,
          query: query,
        ),
    ];
    return CatalogCollection(
      id: catalogId,
      title: title,
      sections: sections,
    );
  }

  List<CatalogSectionQuery> _queriesFor(String catalogId, String title) {
    return switch (catalogId) {
      'playstation' => const [
        CatalogSectionQuery(
          id: 'playstation-gen-1',
          title: '1 · PLAYSTATION',
          platforms: '27',
          ordering: '-rating',
        ),
        CatalogSectionQuery(
          id: 'playstation-gen-2',
          title: '2 · PLAYSTATION 2',
          platforms: '15',
          ordering: '-rating',
        ),
        CatalogSectionQuery(
          id: 'playstation-gen-3',
          title: '3 · PLAYSTATION 3',
          platforms: '16',
          ordering: '-rating',
        ),
        CatalogSectionQuery(
          id: 'playstation-gen-4',
          title: '4 · PLAYSTATION 4',
          platforms: '18',
          ordering: '-added',
        ),
        CatalogSectionQuery(
          id: 'playstation-gen-5',
          title: '5 · PLAYSTATION 5',
          platforms: '187',
          ordering: '-added',
        ),
      ],
      'nintendo' => const [
        CatalogSectionQuery(
          id: 'nintendo-gen-1',
          title: '1 · NES',
          platforms: '49',
          ordering: '-rating',
        ),
        CatalogSectionQuery(
          id: 'nintendo-gen-2',
          title: '2 · SUPER NINTENDO',
          platforms: '79',
          ordering: '-rating',
        ),
        CatalogSectionQuery(
          id: 'nintendo-gen-3',
          title: '3 · NINTENDO 64',
          platforms: '83',
          ordering: '-rating',
        ),
        CatalogSectionQuery(
          id: 'nintendo-gen-4',
          title: '4 · GAMECUBE',
          platforms: '105',
          ordering: '-rating',
        ),
        CatalogSectionQuery(
          id: 'nintendo-gen-5',
          title: '5 · NINTENDO SWITCH',
          platforms: '7',
          ordering: '-added',
        ),
      ],
      'xbox' => const [
        CatalogSectionQuery(
          id: 'xbox-gen-1',
          title: '1 · XBOX',
          platforms: '80',
          ordering: '-rating',
        ),
        CatalogSectionQuery(
          id: 'xbox-gen-2',
          title: '2 · XBOX 360',
          platforms: '14',
          ordering: '-rating',
        ),
        CatalogSectionQuery(
          id: 'xbox-gen-3',
          title: '3 · XBOX ONE',
          platforms: '1',
          ordering: '-added',
        ),
        CatalogSectionQuery(
          id: 'xbox-gen-4',
          title: '4 · XBOX SERIES X|S',
          platforms: '186',
          ordering: '-added',
        ),
      ],
      'novedades' => _consoleQueries(
        catalogId: catalogId,
        ordering: '-released',
        dates: _novedadesDates(),
      ),
      'discover' => _consoleQueries(
        catalogId: catalogId,
        ordering: '-added',
      ),
      'nextgen' => const [
        CatalogSectionQuery(
          id: 'nextgen-playstation',
          title: 'PLAYSTATION',
          platforms: '187',
          ordering: '-added',
        ),
        CatalogSectionQuery(
          id: 'nextgen-nintendo',
          title: 'NINTENDO',
          platforms: '7',
          ordering: '-added',
        ),
        CatalogSectionQuery(
          id: 'nextgen-xbox',
          title: 'XBOX',
          platforms: '186',
          ordering: '-added',
        ),
      ],
      'retros' => const [
        CatalogSectionQuery(
          id: 'retros-playstation',
          title: 'PLAYSTATION',
          platforms: '27,15,17',
          ordering: '-rating',
          dates: '1983-01-01,2008-12-31',
        ),
        CatalogSectionQuery(
          id: 'retros-nintendo',
          title: 'NINTENDO',
          platforms: '49,79,83,105,11,10',
          ordering: '-rating',
          dates: '1983-01-01,2008-12-31',
        ),
        CatalogSectionQuery(
          id: 'retros-xbox',
          title: 'XBOX',
          platforms: '80,14',
          ordering: '-rating',
          dates: '1983-01-01,2008-12-31',
        ),
      ],
      _ => [
        CatalogSectionQuery(
          id: catalogId,
          title: title,
        ),
      ],
    };
  }

  List<CatalogSectionQuery> _consoleQueries({
    required String catalogId,
    required String ordering,
    String? dates,
  }) {
    return [
      CatalogSectionQuery(
        id: '$catalogId-playstation',
        title: 'PLAYSTATION',
        parentPlatforms: 2,
        ordering: ordering,
        dates: dates,
      ),
      CatalogSectionQuery(
        id: '$catalogId-nintendo',
        title: 'NINTENDO',
        parentPlatforms: 7,
        ordering: ordering,
        dates: dates,
      ),
      CatalogSectionQuery(
        id: '$catalogId-xbox',
        title: 'XBOX',
        parentPlatforms: 3,
        ordering: ordering,
        dates: dates,
      ),
    ];
  }

  String? _novedadesDates() {
    for (final query in GetCatalogRowsUseCase.queriesFor(DateTime.now())) {
      if (query.id == 'novedades') {
        return query.dates;
      }
    }
    return null;
  }
}
