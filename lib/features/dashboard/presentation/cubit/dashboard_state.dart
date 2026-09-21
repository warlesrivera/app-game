import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../games/domain/models/catalog_row.dart';

part 'dashboard_state.freezed.dart';

@freezed
abstract class DashboardState with _$DashboardState {
  const factory DashboardState.initial() = DashboardInitial;
  const factory DashboardState.loading() = DashboardLoading;
  const factory DashboardState.loaded(List<CatalogRow> rows) = DashboardLoaded;
  const factory DashboardState.error(String message) = DashboardError;
}
