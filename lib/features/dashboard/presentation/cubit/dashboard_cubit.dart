import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../games/domain/usecases/get_discover_games_usecase.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({required this._getDiscoverGames})
    : super(const DashboardState.initial());

  final GetDiscoverGamesUseCase _getDiscoverGames;

  Future<void> loadDiscoverGames() async {
    emit(const DashboardState.loading());
    try {
      final games = await _getDiscoverGames();
      if (isClosed) {
        return;
      }
      emit(DashboardState.loaded(games));
    } catch (error) {
      if (isClosed) {
        return;
      }
      emit(DashboardState.error(_messageFrom(error)));
    }
  }

  String _messageFrom(Object error) {
    if (error is Failure) {
      return error.message;
    }
    return 'No se pudieron cargar los juegos.';
  }
}
