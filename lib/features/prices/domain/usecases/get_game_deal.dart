import '../models/game_deal.dart';
import '../repositories/price_repository.dart';

class GetGameDeal {
  const GetGameDeal(this._repository);

  final PriceRepository _repository;

  Future<GameDeal?> call(String title) {
    return _repository.findDealByTitle(title);
  }
}
