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
  });

  final String gameId;
  final LibraryStatus status;
  final double? personalRating;
  final String? notes;
  final DateTime? updatedAt;
  final bool priceAlerts;
  final List<String> targetStores;

  LibraryEntry copyWith({
    LibraryStatus? status,
    bool? priceAlerts,
    List<String>? targetStores,
  }) {
    return LibraryEntry(
      gameId: gameId,
      status: status ?? this.status,
      personalRating: personalRating,
      notes: notes,
      updatedAt: updatedAt,
      priceAlerts: priceAlerts ?? this.priceAlerts,
      targetStores: targetStores ?? this.targetStores,
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
  ];
}
