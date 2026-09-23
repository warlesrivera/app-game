import '../../games/domain/models/game.dart';
import '../../library/domain/models/library_entry.dart';
import '../../library/domain/models/library_game.dart';
import '../../library/domain/models/library_status.dart';
import '../../profile/domain/models/player_analysis.dart';
import 'models/advisor_limits.dart';
import 'models/player_vault_context.dart';

enum AdvisorIntent { status, recommend, buy, compare, general }

/// Elige pocos juegos de la biblioteca según la pregunta. La app filtra; Gemini no.
final class AdvisorContextBuilder {
  const AdvisorContextBuilder._();

  static AdvisorIntent intentOf(String question) {
    final q = foldAdvisorText(question);
    if (_hasAny(q, const [
      'cuantos',
      'cuantas',
      'tengo este',
      'ya lo tengo',
      'ya termine',
      'estoy jugando',
      'juego actual',
    ])) {
      return AdvisorIntent.status;
    }
    if (_hasAny(q, const ['compar', 'versus', ' vs '])) {
      return AdvisorIntent.compare;
    }
    if (_hasAny(q, const [
      'comprar',
      'wishlist',
      'pendiente',
      'oferta',
      'descuento',
    ])) {
      return AdvisorIntent.buy;
    }
    if (_hasAny(q, const [
      'recomien',
      'despues',
      'siguiente',
      'que jugar',
      'me gustaria',
      'encaja',
    ])) {
      return AdvisorIntent.recommend;
    }
    return AdvisorIntent.general;
  }

  static PlayerVaultContext build({
    required String question,
    required Game focus,
    required List<LibraryEntry> entries,
    required Map<String, Game> games,
    PlayerAnalysis? analysis,
  }) {
    final intent = intentOf(question);
    final stats = LibraryStats.fromEntries(entries);
    final focusEntry = _entryOf(entries, focus.id);

    final playing = _names(
      _byStatus(entries, LibraryStatus.playing),
      games,
      AdvisorLimits.maxPerStatus,
    );
    final favorites = _names(
      _favorites(entries),
      games,
      AdvisorLimits.maxFavorites,
    );

    var completed = <String>[];
    var abandoned = <String>[];
    var wishlist = <String>[];

    switch (intent) {
      case AdvisorIntent.status:
      case AdvisorIntent.general:
        completed = _names(
          _byStatus(entries, LibraryStatus.completed),
          games,
          2,
        );
      case AdvisorIntent.recommend:
        completed = _names(
          _byStatus(entries, LibraryStatus.completed),
          games,
          2,
        );
        abandoned = _names(
          _byStatus(entries, LibraryStatus.abandoned),
          games,
          AdvisorLimits.maxPerStatus,
        );
        wishlist = _names(
          _byStatus(entries, LibraryStatus.wishlist),
          games,
          AdvisorLimits.maxPerStatus,
        );
      case AdvisorIntent.buy:
        wishlist = _names(
          _byStatus(entries, LibraryStatus.wishlist),
          games,
          AdvisorLimits.maxPerStatus,
        );
      case AdvisorIntent.compare:
        completed = _names(
          _byStatus(entries, LibraryStatus.completed),
          games,
          AdvisorLimits.maxPerStatus,
        );
        abandoned = _names(
          _byStatus(entries, LibraryStatus.abandoned),
          games,
          2,
        );
    }

    final selectedIds = <String>{
      focus.id,
      ..._ids(_byStatus(entries, LibraryStatus.playing), AdvisorLimits.maxPerStatus),
      ..._ids(_favorites(entries), AdvisorLimits.maxFavorites),
    };

    return PlayerVaultContext(
      focusId: focus.id,
      focusName: focus.name,
      focusStatus: focusEntry?.status.label,
      playing: playing,
      favorites: favorites,
      completed: completed,
      abandoned: abandoned,
      wishlist: wishlist,
      stats: stats,
      profileHint: profileHintOf(analysis),
      fingerprint: [
        focus.id,
        'i:${intent.name}',
        'ids:${(selectedIds.toList()..sort()).join(',')}',
        if (analysis != null) 'p:${analysis.fingerprint}',
      ].join('|'),
    );
  }

  /// IDs a hidratar con RAWG/Hive. Nunca toda la biblioteca.
  static List<String> hydrateIds({
    required String question,
    required String focusId,
    required List<LibraryEntry> entries,
  }) {
    final intent = intentOf(question);
    final ids = <String>{focusId};
    ids.addAll(_ids(_byStatus(entries, LibraryStatus.playing), AdvisorLimits.maxPerStatus));
    ids.addAll(_ids(_favorites(entries), AdvisorLimits.maxFavorites));

    void addStatus(LibraryStatus status, int max) {
      ids.addAll(_ids(_byStatus(entries, status), max));
    }

    switch (intent) {
      case AdvisorIntent.status:
      case AdvisorIntent.general:
        addStatus(LibraryStatus.completed, 2);
      case AdvisorIntent.recommend:
        addStatus(LibraryStatus.completed, 2);
        addStatus(LibraryStatus.abandoned, AdvisorLimits.maxPerStatus);
        addStatus(LibraryStatus.wishlist, AdvisorLimits.maxPerStatus);
      case AdvisorIntent.buy:
        addStatus(LibraryStatus.wishlist, AdvisorLimits.maxPerStatus);
      case AdvisorIntent.compare:
        addStatus(LibraryStatus.completed, AdvisorLimits.maxPerStatus);
        addStatus(LibraryStatus.abandoned, 2);
    }

    if (ids.length > AdvisorLimits.maxRelevantGames + 1) {
      return ids.take(AdvisorLimits.maxRelevantGames + 1).toList();
    }
    return ids.toList();
  }

  static LibraryEntry? _entryOf(List<LibraryEntry> entries, String gameId) {
    for (final entry in entries) {
      if (entry.gameId == gameId) {
        return entry;
      }
    }
    return null;
  }

  static List<LibraryEntry> _byStatus(
    List<LibraryEntry> entries,
    LibraryStatus status,
  ) {
    final matched = [
      for (final entry in entries)
        if (entry.status == status) entry,
    ]..sort((a, b) {
      final left = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final right = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return right.compareTo(left);
    });
    return matched;
  }

  static List<LibraryEntry> _favorites(List<LibraryEntry> entries) {
    return [
      for (final entry in entries)
        if (entry.isFavorite && entry.canBeFavorite) entry,
    ]..sort((a, b) {
      return (a.favoriteRank ?? 9999).compareTo(b.favoriteRank ?? 9999);
    });
  }

  static List<String> _ids(List<LibraryEntry> entries, int max) {
    return [for (final entry in entries.take(max)) entry.gameId];
  }

  static List<String> _names(
    List<LibraryEntry> entries,
    Map<String, Game> games,
    int max,
  ) {
    final names = <String>[];
    for (final entry in entries) {
      if (names.length >= max) {
        break;
      }
      final name = games[entry.gameId]?.name.trim();
      if (name == null || name.isEmpty) {
        continue;
      }
      names.add(name);
    }
    return names;
  }

  static bool _hasAny(String haystack, List<String> needles) {
    for (final needle in needles) {
      if (haystack.contains(needle)) {
        return true;
      }
    }
    return false;
  }
}
