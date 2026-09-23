import '../../../library/domain/models/library_game.dart';
import '../../../profile/domain/models/player_analysis.dart';
import 'advisor_limits.dart';
import 'game_ai_context.dart';

class PlayerVaultContext {
  const PlayerVaultContext({
    required this.focusId,
    required this.focusName,
    this.focusStatus,
    this.playing = const [],
    this.favorites = const [],
    this.completed = const [],
    this.abandoned = const [],
    this.wishlist = const [],
    this.stats = const LibraryStats.empty(),
    this.profileHint,
    this.fingerprint = '',
  });

  final String focusId;
  final String focusName;
  final String? focusStatus;
  final List<String> playing;
  final List<String> favorites;
  final List<String> completed;
  final List<String> abandoned;
  final List<String> wishlist;
  final LibraryStats stats;
  final String? profileHint;
  final String fingerprint;

  bool get hasLibrary =>
      playing.isNotEmpty ||
      favorites.isNotEmpty ||
      completed.isNotEmpty ||
      abandoned.isNotEmpty ||
      wishlist.isNotEmpty ||
      stats.total > 0;

  /// Línea corta para el system prompt. Sin IDs, email ni párrafos.
  String get compactLine {
    final bits = <String>[
      'c${stats.completed}/j${stats.playing}/w${stats.wishlist}/a${stats.abandoned}',
      if (focusStatus != null) 'ficha:$focusStatus',
      if (playing.isNotEmpty) 'jugando:${playing.join(',')}',
      if (favorites.isNotEmpty) 'fav:${favorites.join(',')}',
      if (completed.isNotEmpty) 'ok:${completed.join(',')}',
      if (abandoned.isNotEmpty) 'off:${abandoned.join(',')}',
      if (wishlist.isNotEmpty) 'wish:${wishlist.join(',')}',
      if (profileHint != null) 'perfil:$profileHint',
    ];
    return bits.join('|');
  }

  String? statusOf(String gameName) {
    final needle = foldAdvisorText(gameName);
    if (needle.isEmpty) {
      return null;
    }
    if (_containsName(playing, needle)) {
      return 'jugando';
    }
    if (_containsName(completed, needle) || _containsName(favorites, needle)) {
      return 'completado';
    }
    if (_containsName(abandoned, needle)) {
      return 'abandonado';
    }
    if (_containsName(wishlist, needle)) {
      return 'wishlist';
    }
    return null;
  }

  static bool _containsName(List<String> names, String needle) {
    for (final name in names) {
      final folded = foldAdvisorText(name);
      if (folded == needle || folded.contains(needle) || needle.contains(folded)) {
        return true;
      }
    }
    return false;
  }
}

String foldAdvisorText(String value) {
  final lower = value.toLowerCase().trim();
  const from = 'áàäéèëíìïóòöúùüñ';
  const to = 'aaaeeeiiiooouuun';
  final buffer = StringBuffer();
  for (final unit in lower.runes) {
    final char = String.fromCharCode(unit);
    final index = from.indexOf(char);
    buffer.write(index >= 0 ? to[index] : char);
  }
  return buffer.toString().replaceAll(RegExp(r'[^a-z0-9 ]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
}

String? profileHintOf(PlayerAnalysis? analysis) {
  if (analysis == null || !analysis.hasContent) {
    return null;
  }
  final raw = analysis.summary.isNotEmpty ? analysis.summary : analysis.title;
  return clipText(raw, AdvisorLimits.maxProfileHintChars);
}
