import '../../../library/data/datasources/library_remote_datasource.dart';
import '../../domain/models/game_deal.dart';
import '../../domain/repositories/price_repository.dart';
import '../datasources/cheapshark_remote_datasource.dart';

class PriceRepositoryImpl implements PriceRepository {
  const PriceRepositoryImpl(this._libraryRemote, this._cheapShark);

  final LibraryRemoteDataSource _libraryRemote;
  final CheapSharkRemoteDataSource _cheapShark;

  @override
  Future<void> savePriceAlert({
    required String gameId,
    required bool enabled,
    required List<String> stores,
  }) {
    return _libraryRemote.setPriceAlert(
      gameId: gameId,
      enabled: enabled,
      stores: stores,
    );
  }

  @override
  Future<GameDeal?> findDealByTitle(String title) {
    return _cheapShark.searchByTitle(title);
  }
}
