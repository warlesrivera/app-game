import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../games/domain/models/game.dart';

part 'search_state.freezed.dart';

@freezed
abstract class SearchState with _$SearchState {
  const factory SearchState.initial() = SearchInitial;
  const factory SearchState.loading() = SearchLoading;
  const factory SearchState.loaded(List<Game> games) = SearchLoaded;
  const factory SearchState.error(String message) = SearchError;
}
