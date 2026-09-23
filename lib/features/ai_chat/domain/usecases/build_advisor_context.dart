import '../../../games/domain/models/game.dart';
import '../../../games/domain/usecases/get_games_by_ids.dart';
import '../../../library/domain/models/library_entry.dart';
import '../../../library/domain/usecases/watch_library.dart';
import '../../../profile/data/datasources/player_analysis_remote_datasource.dart';
import '../../../profile/domain/models/player_analysis.dart';
import '../advisor_context_builder.dart';
import '../models/player_vault_context.dart';

class BuildAdvisorContext {
  const BuildAdvisorContext({
    required WatchLibrary watchLibrary,
    required GetGamesByIds getGamesByIds,
    required PlayerAnalysisRemoteDataSource analysisRemote,
  }) : _watchLibrary = watchLibrary,
       _getGamesByIds = getGamesByIds,
       _analysisRemote = analysisRemote;

  final WatchLibrary _watchLibrary;
  final GetGamesByIds _getGamesByIds;
  final PlayerAnalysisRemoteDataSource _analysisRemote;

  Future<PlayerVaultContext> call({
    required String question,
    required Game focus,
  }) async {
    final entries = await _safeEntries();
    final ids = AdvisorContextBuilder.hydrateIds(
      question: question,
      focusId: focus.id,
      entries: entries,
    );
    final games = <String, Game>{focus.id: focus};
    if (ids.length > 1) {
      try {
        for (final game in await _getGamesByIds(ids)) {
          games[game.id] = game;
        }
      } catch (_) {}
    }

    return AdvisorContextBuilder.build(
      question: question,
      focus: focus,
      entries: entries,
      games: games,
      analysis: await _safeAnalysis(),
    );
  }

  Future<List<LibraryEntry>> _safeEntries() async {
    try {
      return await _watchLibrary().first.timeout(
        const Duration(seconds: 2),
        onTimeout: () => const <LibraryEntry>[],
      );
    } catch (_) {
      return const [];
    }
  }

  Future<PlayerAnalysis?> _safeAnalysis() async {
    try {
      return await _analysisRemote.get();
    } catch (_) {
      return null;
    }
  }
}
