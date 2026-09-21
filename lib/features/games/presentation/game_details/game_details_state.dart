import 'package:equatable/equatable.dart';

import '../../domain/models/game.dart';
import '../../domain/models/game_guide.dart';
import '../../domain/models/game_video.dart';

final class GameDetailsState extends Equatable {
  const GameDetailsState({
    required this.game,
    this.videos = const <GameVideo>[],
    this.loadingDescription = false,
    this.loadingVideos = false,
    this.translating = false,
    this.loadingGuide = false,
    this.guide,
    this.error,
  });

  final Game game;
  final List<GameVideo> videos;
  final bool loadingDescription;
  final bool loadingVideos;
  final bool translating;
  final bool loadingGuide;
  final GameGuide? guide;
  final String? error;

  String? get synopsis {
    final spanish = game.descriptionEs?.trim();
    if (spanish != null && spanish.isNotEmpty) {
      return spanish;
    }
    final original = game.description?.trim();
    if (original != null && original.isNotEmpty) {
      return original;
    }
    return null;
  }

  GameDetailsState copyWith({
    Game? game,
    List<GameVideo>? videos,
    bool? loadingDescription,
    bool? loadingVideos,
    bool? translating,
    bool? loadingGuide,
    GameGuide? guide,
    String? error,
    bool clearError = false,
  }) {
    return GameDetailsState(
      game: game ?? this.game,
      videos: videos ?? this.videos,
      loadingDescription: loadingDescription ?? this.loadingDescription,
      loadingVideos: loadingVideos ?? this.loadingVideos,
      translating: translating ?? this.translating,
      loadingGuide: loadingGuide ?? this.loadingGuide,
      guide: guide ?? this.guide,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    game,
    videos,
    loadingDescription,
    loadingVideos,
    translating,
    loadingGuide,
    guide,
    error,
  ];
}
