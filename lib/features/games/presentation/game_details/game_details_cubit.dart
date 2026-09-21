import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/models/game.dart';
import '../../domain/usecases/get_game_details.dart';
import '../../domain/usecases/translate_game_description.dart';
import 'game_details_state.dart';

class GameDetailsCubit extends Cubit<GameDetailsState> {
  GameDetailsCubit({
    required Game preview,
    required GetGameDetails getGameDetails,
    TranslateGameDescription? translateDescription,
  }) : _getGameDetails = getGameDetails,
       _translateDescription = translateDescription,
       super(
         GameDetailsState(
           game: preview,
           loadingDescription: !_hasText(preview.description) &&
               !_hasText(preview.descriptionEs),
         ),
       );

  final GetGameDetails _getGameDetails;
  final TranslateGameDescription? _translateDescription;

  Future<void> load() async {
    final id = int.tryParse(state.game.id);
    if (id == null) {
      if (!isClosed) {
        emit(state.copyWith(loadingDescription: false));
      }
      return;
    }

    if (!isClosed) {
      emit(
        state.copyWith(
          loadingDescription:
              !_hasText(state.game.description) &&
              !_hasText(state.game.descriptionEs),
          clearError: true,
        ),
      );
    }

    await _loadDetails(id);
  }

  Future<void> _loadDetails(int id) async {
    try {
      final game = await _getGameDetails(id);
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          game: game.copyWith(
            screenshotUrls: _mergeUrls(
              game.screenshotUrls,
              state.game.screenshotUrls,
            ),
          ),
          loadingDescription: false,
        ),
      );
      await _translateIfNeeded(game);
    } catch (error) {
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          loadingDescription: false,
          error: _messageFrom(error),
        ),
      );
    }
  }

  Future<void> _translateIfNeeded(Game game) async {
    final translate = _translateDescription;
    if (translate == null) {
      return;
    }
    if (game.description == null || game.description!.trim().isEmpty) {
      return;
    }

    emit(state.copyWith(translating: true));
    try {
      final updated = await translate(game);
      if (isClosed) {
        return;
      }
      emit(state.copyWith(game: updated, translating: false));
    } catch (_) {
      if (isClosed) {
        return;
      }
      emit(state.copyWith(translating: false));
    }
  }

  String _messageFrom(Object error) {
    if (error is Failure) {
      return error.message;
    }
    return 'No se pudieron cargar más detalles.';
  }
}

bool _hasText(String? value) {
  return value != null && value.trim().isNotEmpty;
}

List<String> _mergeUrls(List<String> primary, List<String> extra) {
  final merged = <String>[];
  final seen = <String>{};
  for (final url in [...primary, ...extra]) {
    if (url.isNotEmpty && seen.add(url)) {
      merged.add(url);
    }
  }
  return merged;
}
