import '../repositories/price_repository.dart';

class SavePriceAlert {
  const SavePriceAlert(this._repository);

  final PriceRepository _repository;

  Future<void> call({
    required String gameId,
    required bool enabled,
    required List<String> stores,
  }) {
    return _repository.savePriceAlert(
      gameId: gameId,
      enabled: enabled,
      stores: stores,
    );
  }
}
