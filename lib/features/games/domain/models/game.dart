import 'package:freezed_annotation/freezed_annotation.dart';

part 'game.freezed.dart';
part 'game.g.dart';

@freezed
abstract class Game with _$Game {
  const factory Game({
    required String id,
    required String name,
    String? description,
    DateTime? releaseDate,
    String? coverUrl,
    double? rating,
    @Default(<String>[]) List<String> platforms,
    @Default(<String>[]) List<String> genres,
  }) = _Game;

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
}
