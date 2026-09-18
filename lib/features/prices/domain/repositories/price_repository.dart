abstract interface class PriceRepository {
  Future<void> savePriceAlert({
    required String gameId,
    required bool enabled,
    required List<String> stores,
  });
}
