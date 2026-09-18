// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Game _$GameFromJson(Map<String, dynamic> json) => _Game(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  releaseDate: json['releaseDate'] == null
      ? null
      : DateTime.parse(json['releaseDate'] as String),
  coverUrl: json['coverUrl'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  platforms:
      (json['platforms'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  genres:
      (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$GameToJson(_Game instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'releaseDate': instance.releaseDate?.toIso8601String(),
  'coverUrl': instance.coverUrl,
  'rating': instance.rating,
  'platforms': instance.platforms,
  'genres': instance.genres,
};
