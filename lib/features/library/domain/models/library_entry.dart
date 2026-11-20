import 'package:equatable/equatable.dart';

import 'game_console.dart';
import 'game_taste.dart';
import 'library_status.dart';
import 'ownership.dart';

class LibraryEntry extends Equatable {
  const LibraryEntry({
    required this.gameId,
    required this.status,
    this.personalRating,
    this.notes,
    this.updatedAt,
    this.priceAlerts = false,
    this.targetStores = const [],
    this.isFavorite = false,
    this.favoriteRank,
    this.taste,
    this.owned = false,
    this.ownershipFormat,
    this.ownershipStore,
    this.ownershipConsole,
  });

  final String gameId;
  final LibraryStatus status;
  final double? personalRating;
  final String? notes;
  final DateTime? updatedAt;
  final bool priceAlerts;
  final List<String> targetStores;
  final bool isFavorite;
  final int? favoriteRank;

  /// Le gustó o no, aunque lo haya abandonado.
  final GameTaste? taste;

  bool get enjoyed => taste == GameTaste.liked;

  /// Ya lo tiene, aunque siga en la wishlist.
  final bool owned;
  final OwnershipFormat? ownershipFormat;
  final OwnershipStore? ownershipStore;
  final String? ownershipConsole;

  bool get canBeFavorite => status == LibraryStatus.completed;

  String? get ownershipLabel {
    if (!owned) {
      return null;
    }
    final console = GameConsole.bySlug(ownershipConsole)?.label;
    final format = ownershipFormat == OwnershipFormat.physical
        ? 'Físico'
        : ownershipStore?.label;
    if (console != null && format != null) {
      return '$format · $console';
    }
    return console ?? format ?? 'Lo tengo';
  }

  bool get isTopFavorite =>
      isFavorite &&
      canBeFavorite &&
      favoriteRank != null &&
      favoriteRank! >= 1 &&
      favoriteRank! <= 3;

  LibraryEntry copyWith({
    LibraryStatus? status,
    bool? priceAlerts,
    List<String>? targetStores,
    bool? isFavorite,
    int? favoriteRank,
    bool clearFavoriteRank = false,
    GameTaste? taste,
    bool clearTaste = false,
    bool? owned,
    OwnershipFormat? ownershipFormat,
    OwnershipStore? ownershipStore,
    String? ownershipConsole,
    bool clearOwnership = false,
  }) {
    return LibraryEntry(
      gameId: gameId,
      status: status ?? this.status,
      personalRating: personalRating,
      notes: notes,
      updatedAt: updatedAt,
      priceAlerts: priceAlerts ?? this.priceAlerts,
      targetStores: targetStores ?? this.targetStores,
      isFavorite: isFavorite ?? this.isFavorite,
      favoriteRank: clearFavoriteRank
          ? null
          : favoriteRank ?? this.favoriteRank,
      taste: clearTaste ? null : taste ?? this.taste,
      owned: owned ?? this.owned,
      ownershipFormat: clearOwnership
          ? null
          : ownershipFormat ?? this.ownershipFormat,
      ownershipStore: clearOwnership
          ? null
          : ownershipStore ?? this.ownershipStore,
      ownershipConsole: clearOwnership
          ? null
          : ownershipConsole ?? this.ownershipConsole,
    );
  }

  @override
  List<Object?> get props => [
    gameId,
    status,
    personalRating,
    notes,
    updatedAt,
    priceAlerts,
    targetStores,
    isFavorite,
    favoriteRank,
    taste,
    owned,
    ownershipFormat,
    ownershipStore,
    ownershipConsole,
  ];
}
