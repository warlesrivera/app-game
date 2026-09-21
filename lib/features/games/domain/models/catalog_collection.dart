import 'package:equatable/equatable.dart';

import 'game.dart';

class CatalogSectionQuery {
  const CatalogSectionQuery({
    required this.id,
    required this.title,
    this.parentPlatforms,
    this.platforms,
    this.ordering = '-added',
    this.dates,
    this.page = 1,
  });

  final String id;
  final String title;
  final int? parentPlatforms;
  final String? platforms;
  final String ordering;
  final String? dates;
  final int page;
}

class CatalogSection extends Equatable {
  const CatalogSection({
    required this.id,
    required this.title,
    required this.query,
    this.games = const [],
    this.page = 0,
    this.hasMore = true,
    this.loading = false,
    this.loadingMore = false,
  });

  final String id;
  final String title;
  final CatalogSectionQuery query;
  final List<Game> games;
  final int page;
  final bool hasMore;
  final bool loading;
  final bool loadingMore;

  bool get loaded => page > 0;

  CatalogSection copyWith({
    List<Game>? games,
    int? page,
    bool? hasMore,
    bool? loading,
    bool? loadingMore,
  }) {
    return CatalogSection(
      id: id,
      title: title,
      query: query,
      games: games ?? this.games,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    query.id,
    games,
    page,
    hasMore,
    loading,
    loadingMore,
  ];
}

class CatalogCollection extends Equatable {
  const CatalogCollection({
    required this.id,
    required this.title,
    required this.sections,
  });

  final String id;
  final String title;
  final List<CatalogSection> sections;

  @override
  List<Object?> get props => [id, title, sections];
}
