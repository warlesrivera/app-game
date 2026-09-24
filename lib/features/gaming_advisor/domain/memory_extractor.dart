import 'models/gaming_models.dart';

abstract final class MemoryExtractor {
  static List<GamingMemory> extract({
    required String question,
    required List<GamingMemory> existing,
    DateTime? now,
  }) {
    final text = question.trim();
    if (text.isEmpty || _isFactual(text)) {
      return const [];
    }
    final category = _category(text);
    if (category == null) {
      return const [];
    }
    final stamp = now ?? DateTime.now();
    final folded = _fold(text);
    for (final memory in existing) {
      if (_fold(memory.content) == folded || _similar(memory.content, text)) {
        return [
          memory.copyWith(
            confidence: (memory.confidence + 0.05).clamp(0, 0.99),
            importance: memory.importance,
            updatedAt: stamp,
          ),
        ];
      }
    }
    return [
      GamingMemory(
        id: 'mem_${stamp.microsecondsSinceEpoch}',
        category: category,
        content: text,
        importance: category == MemoryCategory.dislike ? 0.8 : 0.7,
        confidence: 0.7,
        createdAt: stamp,
        updatedAt: stamp,
      ),
    ];
  }

  static bool _isFactual(String text) {
    final folded = _fold(text);
    const needles = [
      'cuanto dura',
      'cuantos',
      'cuantas',
      'cuando sale',
      'ya termine',
      'tengo este',
    ];
    return needles.any(folded.contains);
  }

  static MemoryCategory? _category(String text) {
    final folded = _fold(text);
    if (folded.contains('no me gusta') ||
        folded.contains('me aburre') ||
        folded.contains('odio') ||
        folded.contains('me frustra')) {
      return MemoryCategory.dislike;
    }
    if (folded.contains('fin de semana') || folded.contains('suelo jugar')) {
      return MemoryCategory.habit;
    }
    if (folded.contains('me gusta') ||
        folded.contains('prefiero') ||
        folded.contains('me encant')) {
      return MemoryCategory.preference;
    }
    return null;
  }

  static bool _similar(String left, String right) {
    final a = _fold(left).split(' ').where((part) => part.length > 3).toSet();
    final b = _fold(right).split(' ').where((part) => part.length > 3).toSet();
    if (a.isEmpty || b.isEmpty) {
      return false;
    }
    final shared = a.intersection(b).length;
    return shared / (a.length > b.length ? a.length : b.length) >= 0.6;
  }

  static String _fold(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
