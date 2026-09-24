import '../../library/domain/models/library_game.dart';
import 'models/gaming_models.dart';

abstract final class AdvisorBudget {
  static const maxRelevantMemories = 8;
  static const maxRelevantGames = 5;
  static const maxRecentMessages = 6;
}

class GamingContext {
  const GamingContext({
    required this.profileLine,
    required this.memories,
    required this.games,
    required this.currentGame,
    required this.summary,
    required this.recent,
    required this.question,
    required this.fingerprint,
  });

  final String profileLine;
  final List<GamingMemory> memories;
  final List<LibraryGame> games;
  final LibraryGame? currentGame;
  final String summary;
  final List<AdvisorMessage> recent;
  final String question;
  final String fingerprint;

  String prompt() {
    final buffer = StringBuffer()
      ..writeln('PLAYER PROFILE')
      ..writeln(profileLine)
      ..writeln('RELEVANT MEMORIES');
    if (memories.isEmpty) {
      buffer.writeln('- ninguna');
    } else {
      for (final memory in memories) {
        buffer.writeln('- ${memory.content}');
      }
    }
    buffer.writeln('RELEVANT GAMES');
    if (games.isEmpty) {
      buffer.writeln('- ninguno');
    } else {
      for (final item in games) {
        buffer.writeln(
          '- ${item.game.name} (${item.entry.status.label})',
        );
      }
    }
    buffer
      ..writeln('CURRENT CONTEXT')
      ..writeln(currentGame == null ? 'Sin juego actual.' : currentGame!.game.name);
    if (summary.trim().isNotEmpty) {
      buffer.writeln('SUMMARY\n$summary');
    }
    buffer
      ..writeln('QUESTION')
      ..write(question);
    return buffer.toString();
  }
}

abstract final class GamingContextBuilder {
  static GamingContext build({
    required String question,
    required GamingProfile profile,
    required List<GamingMemory> memories,
    required List<LibraryGame> library,
    required List<AdvisorMessage> history,
    LibraryGame? focus,
  }) {
    final tokens = _tokens(question);
    final rankedMemories = [...memories]..sort((a, b) {
      final score = _memoryScore(b, tokens) - _memoryScore(a, tokens);
      if (score != 0) {
        return score;
      }
      return b.confidence.compareTo(a.confidence);
    });
    final pickedMemories = rankedMemories
        .where((memory) => _memoryScore(memory, tokens) > 0 || tokens.isEmpty)
        .take(AdvisorBudget.maxRelevantMemories)
        .toList();
    if (pickedMemories.length < 3) {
      for (final memory in rankedMemories) {
        if (pickedMemories.length >= 3) {
          break;
        }
        if (!pickedMemories.any((item) => item.id == memory.id)) {
          pickedMemories.add(memory);
        }
      }
    }

    final current = focus ??
        library.cast<LibraryGame?>().firstWhere(
          (item) => item!.game.id == profile.currentGameId,
          orElse: () => library.cast<LibraryGame?>().firstWhere(
            (item) => item!.entry.status.name == 'playing',
            orElse: () => null,
          ),
        );

    final rankedGames = [...library]..sort(
      (a, b) => _gameScore(b, tokens, profile, current).compareTo(
        _gameScore(a, tokens, profile, current),
      ),
    );
    final pickedGames = <LibraryGame>[];
    if (current != null) {
      pickedGames.add(current);
    }
    for (final item in rankedGames) {
      if (pickedGames.length >= AdvisorBudget.maxRelevantGames) {
        break;
      }
      if (pickedGames.every((picked) => picked.game.id != item.game.id)) {
        pickedGames.add(item);
      }
    }

    final recent = history.length <= AdvisorBudget.maxRecentMessages
        ? history
        : history.sublist(history.length - AdvisorBudget.maxRecentMessages);

    return GamingContext(
      profileLine: profile.compactLine(),
      memories: pickedMemories.take(AdvisorBudget.maxRelevantMemories).toList(),
      games: pickedGames,
      currentGame: current,
      summary: profile.conversationSummary,
      recent: recent,
      question: question.trim(),
      fingerprint:
          '${profile.version}|${pickedGames.map((item) => item.game.id).join(',')}|${pickedMemories.map((item) => item.id).join(',')}',
    );
  }

  static int _memoryScore(GamingMemory memory, Set<String> tokens) {
    final text = _tokens(memory.content);
    var score = text.intersection(tokens).length * 2;
    if (memory.category == MemoryCategory.preference ||
        memory.category == MemoryCategory.dislike) {
      score += 1;
    }
    return score;
  }

  static int _gameScore(
    LibraryGame item,
    Set<String> tokens,
    GamingProfile profile,
    LibraryGame? current,
  ) {
    var score = _tokens(item.game.name).intersection(tokens).length * 5;
    score += _tokens(item.game.genres.join(' ')).intersection(tokens).length;
    if (item.game.id == current?.game.id) {
      score += 4;
    }
    if (item.entry.status.name == 'wishlist') {
      score += 2;
    }
    if (item.entry.isFavorite) {
      score += 2;
    }
    if (profile.likes.any((like) => _tokens(like).intersection(tokens).isNotEmpty)) {
      score += 1;
    }
    return score;
  }

  static Set<String> _tokens(String raw) {
    return raw
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9áéíóúñü ]'), ' ')
        .split(RegExp(r'\s+'))
        .where((token) => token.length > 2)
        .toSet();
  }
}
