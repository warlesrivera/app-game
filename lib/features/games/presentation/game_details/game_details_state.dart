import 'package:equatable/equatable.dart';

import '../../domain/models/game.dart';

final class GameDetailsState extends Equatable {
  const GameDetailsState({
    required this.game,
    this.loadingDescription = false,
    this.translating = false,
    this.error,
  });

  final Game game;
  final bool loadingDescription;
  final bool translating;
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
    bool? loadingDescription,
    bool? translating,
    String? error,
    bool clearError = false,
  }) {
    return GameDetailsState(
      game: game ?? this.game,
      loadingDescription: loadingDescription ?? this.loadingDescription,
      translating: translating ?? this.translating,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    game,
    loadingDescription,
    translating,
    error,
  ];
}
