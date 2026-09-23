import 'models/game_ai_context.dart';
import 'models/player_vault_context.dart';

/// Resuelve preguntas factuales con la biblioteca. Cero tokens de Gemini.
final class LocalAdvisorResolver {
  const LocalAdvisorResolver._();

  static String? resolve({
    required String question,
    required PlayerVaultContext vault,
    GameAiContext? game,
  }) {
    final q = foldAdvisorText(question);
    if (q.isEmpty || q.length > 90) {
      return null;
    }
    if (_isReasoning(q)) {
      return null;
    }

    if (_asksCount(q, const ['complet', 'termine'])) {
      return 'Tienes ${vault.stats.completed} juegos completados.';
    }
    if (_asksCount(q, const ['wishlist', 'pendiente', 'deseos'])) {
      return _listOrCount(
        count: vault.stats.wishlist,
        names: vault.wishlist,
        empty: 'No tienes juegos en wishlist.',
        one: (name) => 'En wishlist tienes $name.',
        many: (count, names) =>
            'Tienes $count en wishlist${names.isEmpty ? '.' : ': ${names.join(', ')}.'}',
      );
    }
    if (_asksCount(q, const ['abandon', 'deje'])) {
      return 'Tienes ${vault.stats.abandoned} juegos abandonados.';
    }
    if (_asksCount(q, const ['jugando', 'en curso'])) {
      return _playingAnswer(vault);
    }
    if (_asksCount(q, const ['juego', 'juegos']) &&
        (q.contains('cuantos') || q.contains('cuantas'))) {
      return 'En tu biblioteca hay ${vault.stats.total} juegos: '
          '${vault.stats.playing} jugando, ${vault.stats.completed} completados, '
          '${vault.stats.wishlist} en wishlist y ${vault.stats.abandoned} abandonados.';
    }

    if (q.contains('estoy jugando') || q.contains('juego actual')) {
      return _playingAnswer(vault);
    }

    if (q.contains('cuando sale') && game?.year != null) {
      return '${game!.name} salió o está fechado en ${game.year}.';
    }

    if (q.contains('ya termine') || q.contains('lo complete') || q.contains('ya lo termine')) {
      final status = vault.focusStatus?.toLowerCase();
      if (status == 'completado') {
        return 'Sí: ${vault.focusName} está marcado como completado.';
      }
      if (status != null) {
        return '${vault.focusName} está como $status, no como completado.';
      }
      return '${vault.focusName} no está en tu biblioteca todavía.';
    }

    if (q.contains('tengo') && (q.contains('este') || q.contains(foldAdvisorText(vault.focusName)))) {
      if (vault.focusStatus != null) {
        return 'Sí: ${vault.focusName} está en tu biblioteca como ${vault.focusStatus}.';
      }
      return '${vault.focusName} no está en tu biblioteca todavía.';
    }

    return null;
  }

  static bool _isReasoning(String q) {
    return q.contains('porque') ||
        q.contains('recomien') ||
        q.contains('compar') ||
        q.contains('gustaria') ||
        q.contains('encaja') ||
        q.contains('mejor que') ||
        q.contains('despues de');
  }

  static bool _asksCount(String q, List<String> topics) {
    if (!q.contains('cuantos') && !q.contains('cuantas') && !q.contains('cuanto')) {
      return false;
    }
    for (final topic in topics) {
      if (q.contains(topic)) {
        return true;
      }
    }
    return false;
  }

  static String _playingAnswer(PlayerVaultContext vault) {
    if (vault.playing.isEmpty) {
      if (vault.stats.playing == 0) {
        return 'No tienes ningún juego marcado como jugando.';
      }
      return 'Tienes ${vault.stats.playing} juegos en curso.';
    }
    if (vault.playing.length == 1) {
      return 'Estás jugando ${vault.playing.first}.';
    }
    return 'Estás jugando: ${vault.playing.join(', ')}.';
  }

  static String _listOrCount({
    required int count,
    required List<String> names,
    required String empty,
    required String Function(String name) one,
    required String Function(int count, List<String> names) many,
  }) {
    if (count == 0) {
      return empty;
    }
    if (count == 1 && names.length == 1) {
      return one(names.first);
    }
    return many(count, names);
  }
}
