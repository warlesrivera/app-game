import '../models/game_deal.dart';

abstract interface class PriceRepository {
  Future<void> savePriceAlert({
    required String gameId,
    required bool enabled,
    required List<String> stores,
  });

  Future<GameDeal?> findDealByTitle(String title);
}
