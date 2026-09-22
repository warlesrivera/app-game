import 'package:equatable/equatable.dart';

import '../../../prices/domain/models/game_deal.dart';
import '../../domain/models/game.dart';
import '../../domain/models/game_guide.dart';

final class GameDetailsState extends Equatable {
  const GameDetailsState({
    required this.game,
    this.loadingDescription = false,
    this.translating = false,
    this.loadingLore = false,
    this.loadingDeal = false,
    this.lore,
    this.deal,
    this.error,
  });

  final Game game;
  final bool loadingDescription;
  final bool translating;
  final bool loadingLore;
  final bool loadingDeal;
  final GameGuide? lore;
  final GameDeal? deal;
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
    bool? loadingLore,
    bool? loadingDeal,
    GameGuide? lore,
    GameDeal? deal,
    String? error,
    bool clearError = false,
  }) {
    return GameDetailsState(
      game: game ?? this.game,
      loadingDescription: loadingDescription ?? this.loadingDescription,
      translating: translating ?? this.translating,
      loadingLore: loadingLore ?? this.loadingLore,
      loadingDeal: loadingDeal ?? this.loadingDeal,
      lore: lore ?? this.lore,
      deal: deal ?? this.deal,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    game,
    loadingDescription,
    translating,
    loadingLore,
    loadingDeal,
    lore,
    deal,
    error,
  ];
}
