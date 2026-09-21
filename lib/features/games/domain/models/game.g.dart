// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Game _$GameFromJson(Map<String, dynamic> json) => _Game(
  id: json['id'] as String,
  name: json['name'] as String,
  description: _readDescription(json, 'description') as String?,
  releaseDate: json['releaseDate'] == null
      ? null
      : DateTime.parse(json['releaseDate'] as String),
  coverUrl: json['coverUrl'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  platforms:
      (json['platforms'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  platformSlugs:
      (json['platformSlugs'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  genres:
      (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  screenshotUrls:
      (json['screenshotUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  developers:
      (json['developers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  publishers:
      (json['publishers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  stores:
      (json['stores'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  isDetailed: json['isDetailed'] as bool? ?? false,
  website: json['website'] as String?,
  metacritic: (json['metacritic'] as num?)?.toInt(),
  playtime: (json['playtime'] as num?)?.toInt(),
  ratingsCount: (json['ratingsCount'] as num?)?.toInt(),
  esrbRating: json['esrbRating'] as String?,
  descriptionEs: json['descriptionEs'] as String?,
  trailerUrl: json['trailerUrl'] as String?,
  trailerPreviewUrl: json['trailerPreviewUrl'] as String?,
  redditUrl: json['redditUrl'] as String?,
);

Map<String, dynamic> _$GameToJson(_Game instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'releaseDate': instance.releaseDate?.toIso8601String(),
  'coverUrl': instance.coverUrl,
  'rating': instance.rating,
  'platforms': instance.platforms,
  'platformSlugs': instance.platformSlugs,
  'genres': instance.genres,
  'screenshotUrls': instance.screenshotUrls,
  'developers': instance.developers,
  'publishers': instance.publishers,
  'tags': instance.tags,
  'stores': instance.stores,
  'isDetailed': instance.isDetailed,
  'website': instance.website,
  'metacritic': instance.metacritic,
  'playtime': instance.playtime,
  'ratingsCount': instance.ratingsCount,
  'esrbRating': instance.esrbRating,
  'descriptionEs': instance.descriptionEs,
  'trailerUrl': instance.trailerUrl,
  'trailerPreviewUrl': instance.trailerPreviewUrl,
  'redditUrl': instance.redditUrl,
};
