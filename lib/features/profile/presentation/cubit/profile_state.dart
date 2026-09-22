import 'package:equatable/equatable.dart';

import '../../domain/models/genre_radar.dart';
import '../../domain/models/player_analysis.dart';

final class ProfileInsightState extends Equatable {
  const ProfileInsightState({
    this.radar = const GenreRadar.empty(),
    this.analysis,
    this.fingerprint = '',
    this.loadingLore = false,
    this.needsSync = false,
    this.error,
  });

  final GenreRadar radar;
  final PlayerAnalysis? analysis;
  final String fingerprint;
  final bool loadingLore;
  final bool needsSync;
  final String? error;

  String? get lore {
    final current = analysis;
    if (current == null || !current.hasContent) {
      return null;
    }
    if (current.summary.isEmpty) {
      return current.title;
    }
    return '${current.title}\n${current.summary}';
  }

  ProfileInsightState copyWith({
    GenreRadar? radar,
    PlayerAnalysis? analysis,
    String? fingerprint,
    bool? loadingLore,
    bool? needsSync,
    String? error,
    bool clearAnalysis = false,
    bool clearError = false,
  }) {
    return ProfileInsightState(
      radar: radar ?? this.radar,
      analysis: clearAnalysis ? null : analysis ?? this.analysis,
      fingerprint: fingerprint ?? this.fingerprint,
      loadingLore: loadingLore ?? this.loadingLore,
      needsSync: needsSync ?? this.needsSync,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    radar,
    analysis,
    fingerprint,
    loadingLore,
    needsSync,
    error,
  ];
}
