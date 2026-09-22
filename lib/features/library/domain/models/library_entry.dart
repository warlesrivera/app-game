import 'package:equatable/equatable.dart';

import 'library_status.dart';

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

  bool get canBeFavorite => status == LibraryStatus.completed;

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
  ];
}
