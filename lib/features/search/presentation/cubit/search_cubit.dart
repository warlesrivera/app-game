import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../games/domain/usecases/search_games_usecase.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit({required SearchGamesUseCase searchGames})
    : _searchGames = searchGames,
      super(const SearchState.initial());

  static const Duration debounceDuration = Duration(milliseconds: 450);

  final SearchGamesUseCase _searchGames;
  Timer? _debounce;
  int _requestId = 0;

  void onQueryChanged(String query) {
    final trimmed = query.trim();
    _debounce?.cancel();

    if (trimmed.isEmpty) {
      _requestId += 1;
      emit(const SearchState.initial());
      return;
    }

    _debounce = Timer(debounceDuration, () => _search(trimmed));
  }

  Future<void> _search(String query) async {
    final requestId = ++_requestId;
    emit(const SearchState.loading());

    try {
      final games = await _searchGames(query);
      if (isClosed || requestId != _requestId) {
        return;
      }
      emit(SearchState.loaded(games));
    } catch (error) {
      if (isClosed || requestId != _requestId) {
        return;
      }
      emit(SearchState.error(_messageFrom(error)));
    }
  }

  String _messageFrom(Object error) {
    if (error is Failure) {
      return error.message;
    }
    return 'No se pudieron buscar juegos.';
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
