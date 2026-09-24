import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../games/domain/usecases/get_games_by_ids.dart';
import '../../../library/domain/models/library_entry.dart';
import '../../../library/domain/models/library_game.dart';
import '../../../library/domain/models/library_status.dart';
import '../../../library/domain/usecases/set_game_status.dart';
import '../../../library/domain/usecases/watch_library.dart';
import '../../domain/advisor_logic.dart';
import '../../domain/models/gaming_models.dart';
import '../../domain/repositories/gaming_advisor_repository.dart';
import '../../domain/usecases/ask_gaming_advisor.dart';
import 'gaming_advisor_state.dart';

class GamingAdvisorCubit extends Cubit<GamingAdvisorState> {
  GamingAdvisorCubit({
    required GamingAdvisorRepository repository,
    required AskGamingAdvisor askGamingAdvisor,
    required WatchLibrary watchLibrary,
    required GetGamesByIds getGamesByIds,
    required SetGameStatus setGameStatus,
  }) : _repository = repository,
       _ask = askGamingAdvisor,
       _watchLibrary = watchLibrary,
       _getGamesByIds = getGamesByIds,
       _setGameStatus = setGameStatus,
       super(const GamingAdvisorState());

  final GamingAdvisorRepository _repository;
  final AskGamingAdvisor _ask;
  final WatchLibrary _watchLibrary;
  final GetGamesByIds _getGamesByIds;
  final SetGameStatus _setGameStatus;

  Future<void> loadAdvisor() async {
    emit(state.copyWith(status: AdvisorStatus.loading, clearError: true));
    try {
      final profile = await _repository.getProfile();
      final memories = await _repository.getMemories();
      final messages = await _repository.getMessages();
      final library = await _library();
      emit(
        state.copyWith(
          status: AdvisorStatus.loaded,
          profile: profile,
          memories: memories,
          messages: messages,
          upcoming: GamingViews.upcoming(library),
          timeline: GamingViews.timeline(library),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AdvisorStatus.error,
          error: 'No pude cargar el advisor.',
        ),
      );
    }
  }

  Future<void> askQuestion(String question, {String? focusGameId}) async {
    final text = question.trim();
    if (text.isEmpty || state.status == AdvisorStatus.sending) {
      return;
    }
    final user = AdvisorMessage(
      id: 'u_${DateTime.now().microsecondsSinceEpoch}',
      role: 'user',
      text: text,
      createdAt: DateTime.now(),
    );
    emit(
      state.copyWith(
        status: AdvisorStatus.sending,
        messages: [...state.messages, user],
        notice: 'Analizando tus gustos...',
        clearError: true,
      ),
    );
    await _repository.saveMessage(user);
    try {
      final reply = await _ask(
        question: text,
        profile: state.profile,
        memories: state.memories,
        history: state.messages,
        focusGameId: focusGameId,
      );
      var memories = state.memories;
      for (final memory in reply.memories) {
        await _repository.saveMemory(memory);
        memories = [
          for (final current in memories)
            if (current.id != memory.id) current,
          memory,
        ];
      }
      var profile = state.profile;
      if (reply.summary != null) {
        profile = profile.copyWith(conversationSummary: reply.summary);
        await _repository.saveProfile(profile);
      }
      final assistant = AdvisorMessage(
        id: 'a_${DateTime.now().microsecondsSinceEpoch}',
        role: 'assistant',
        text: reply.text,
        cards: reply.cards,
        createdAt: DateTime.now(),
      );
      await _repository.saveMessage(assistant);
      emit(
        state.copyWith(
          status: AdvisorStatus.success,
          messages: [...state.messages, assistant],
          memories: memories,
          profile: profile,
          clearNotice: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AdvisorStatus.error,
          error: 'No pude consultar el asistente ahora.',
          clearNotice: true,
        ),
      );
    }
  }

  Future<void> refreshProfile() => loadAdvisor();

  Future<void> updatePreference(GamingProfile profile) async {
    await _repository.saveProfile(profile);
    emit(state.copyWith(profile: profile, status: AdvisorStatus.loaded));
  }

  Future<void> setCurrentGame(String gameId) async {
    final profile = state.profile.copyWith(
      currentGameId: gameId,
      lastPlayedAt: DateTime.now(),
      version: state.profile.version + 1,
    );
    await _repository.saveProfile(profile);
    await _setGameStatus(gameId: gameId, status: LibraryStatus.playing);
    emit(state.copyWith(profile: profile));
  }

  Future<void> saveMemory(GamingMemory memory) async {
    await _repository.saveMemory(memory);
    final memories = [
      for (final current in state.memories)
        if (current.id != memory.id) current,
      memory,
    ];
    emit(state.copyWith(memories: memories));
  }

  Future<void> deleteMemory(String id) async {
    await _repository.deleteMemory(id);
    emit(
      state.copyWith(
        memories: [
          for (final memory in state.memories)
            if (memory.id != id) memory,
        ],
      ),
    );
  }

  Future<void> generateRecommendations() {
    return askQuestion('¿Qué juego debería jugar ahora?');
  }

  Future<void> clearConversation() async {
    await _repository.clearMessages();
    emit(state.copyWith(messages: const [], status: AdvisorStatus.loaded));
  }

  Future<void> saveExperience(GameExperience experience) {
    return _repository.saveExperience(experience);
  }

  Future<List<LibraryGame>> _library() async {
    List<LibraryEntry> entries;
    try {
      entries = await _watchLibrary().first.timeout(
        const Duration(seconds: 2),
        onTimeout: () => const [],
      );
    } catch (_) {
      return const [];
    }
    if (entries.isEmpty) {
      return const [];
    }
    final games = await _getGamesByIds([for (final entry in entries) entry.gameId]);
    final byId = {for (final game in games) game.id: game};
    return [
      for (final entry in entries)
        if (byId[entry.gameId] != null)
          LibraryGame(game: byId[entry.gameId]!, entry: entry),
    ];
  }
}
