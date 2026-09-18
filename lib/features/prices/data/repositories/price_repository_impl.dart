import '../../../library/data/datasources/library_remote_datasource.dart';
import '../../domain/repositories/price_repository.dart';

class PriceRepositoryImpl implements PriceRepository {
  const PriceRepositoryImpl(this._libraryRemote);

  final LibraryRemoteDataSource _libraryRemote;

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
}
