import 'package:equatable/equatable.dart';

import 'game.dart';

class CatalogQuery {
  const CatalogQuery({
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

class CatalogRow extends Equatable {
  const CatalogRow({
    required this.id,
    required this.title,
    required this.games,
  });

  final String id;
  final String title;
  final List<Game> games;

  @override
  List<Object?> get props => [id, title, games];
}
