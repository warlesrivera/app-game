import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../games/domain/usecases/get_catalog_rows.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({required GetCatalogRowsUseCase getCatalogRows})
    : _getCatalogRows = getCatalogRows,
      super(const DashboardState.initial());

  final GetCatalogRowsUseCase _getCatalogRows;

  Future<void> loadDiscoverGames() async {
    emit(const DashboardState.loading());
    try {
      final rows = await _getCatalogRows();
      if (isClosed) {
        return;
      }
      emit(DashboardState.loaded(rows));
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
