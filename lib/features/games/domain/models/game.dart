import 'package:freezed_annotation/freezed_annotation.dart';

part 'game.freezed.dart';
part 'game.g.dart';

Object? _readDescription(Map<dynamic, dynamic> json, String key) {
  return json['description_raw'] ?? json[key];
}

@freezed
abstract class Game with _$Game {
  const factory Game({
    required String id,
    required String name,
    @JsonKey(readValue: _readDescription) String? description,
    DateTime? releaseDate,
    String? coverUrl,
    double? rating,
    @Default(<String>[]) List<String> platforms,
    @Default(<String>[]) List<String> platformSlugs,
    @Default(<String>[]) List<String> genres,
    @Default(<String>[]) List<String> screenshotUrls,
    @Default(<String>[]) List<String> developers,
    @Default(<String>[]) List<String> publishers,
    @Default(<String>[]) List<String> tags,
    @Default(<String>[]) List<String> stores,
    @Default(false) bool isDetailed,
    String? website,
    int? metacritic,
    int? playtime,
    int? ratingsCount,
    String? esrbRating,
    String? descriptionEs,
    String? trailerUrl,
    String? trailerPreviewUrl,
    String? redditUrl,
  }) = _Game;

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
}
