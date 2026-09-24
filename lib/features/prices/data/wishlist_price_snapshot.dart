import 'package:hive_flutter/hive_flutter.dart';

import '../../library/domain/models/library_game.dart';
import '../../library/domain/models/library_status.dart';

/// Copia local de la wishlist para el worker en segundo plano.
class WishlistPriceSnapshot {
  WishlistPriceSnapshot(this._box);

  static const boxName = 'price_watch';
  static const _key = 'wishlist';

  final Box<dynamic> _box;

  Future<void> sync(List<LibraryGame> games) async {
    final previous = {
      for (final item in read()) item.id: item,
    };
    final next = <WatchedPrice>[
      for (final item in games)
        if (item.entry.status == LibraryStatus.wishlist)
          WatchedPrice(
            id: item.game.id,
            name: item.game.name,
            lastPrice: previous[item.game.id]?.lastPrice,
          ),
    ];
    await _write(next);
  }

  Future<void> clear() => _box.delete(_key);

  List<WatchedPrice> read() {
    final raw = _box.get(_key);
    if (raw is! List) {
      return const [];
    }
    return [
      for (final item in raw)
        if (item is Map) WatchedPrice.fromJson(Map<String, dynamic>.from(item)),
    ];
  }

  Future<void> updatePrice({
    required String id,
    required double price,
  }) async {
    final items = [
      for (final item in read())
        if (item.id == id) item.copyWith(lastPrice: price) else item,
    ];
    await _write(items);
  }

  Future<void> _write(List<WatchedPrice> items) {
    return _box.put(_key, [for (final item in items) item.toJson()]);
  }
}

class WatchedPrice {
  const WatchedPrice({
    required this.id,
    required this.name,
    this.lastPrice,
  });

  final String id;
  final String name;
  final double? lastPrice;

  WatchedPrice copyWith({double? lastPrice}) {
    return WatchedPrice(id: id, name: name, lastPrice: lastPrice ?? this.lastPrice);
  }

  factory WatchedPrice.fromJson(Map<String, dynamic> json) {
    final raw = json['lastPrice'];
    return WatchedPrice(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      lastPrice: raw is num ? raw.toDouble() : double.tryParse('$raw'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'lastPrice': lastPrice,
  };
}
