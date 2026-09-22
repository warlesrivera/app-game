import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/game_deal.dart';

class CheapSharkRemoteDataSource {
  CheapSharkRemoteDataSource({Dio? dio, Box<dynamic>? cache})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://www.cheapshark.com',
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
              headers: const {
                'User-Agent': 'GameVault/1.0 (https://gamevault.app)',
              },
            ),
          ),
      _cache = cache;

  static const _dealTtl = Duration(minutes: 60);
  static const _storesTtl = Duration(days: 7);
  static const _storesKey = 'cheapshark_stores_v1';

  final Dio _dio;
  final Box<dynamic>? _cache;

  Future<GameDeal?> searchByTitle(String title) async {
    final query = title.trim();
    if (query.isEmpty) {
      return null;
    }

    final cached = _readDealCache(query);
    if (cached != null) {
      return cached.isEmpty ? null : cached;
    }

    try {
      final response = await _dio.get<dynamic>(
        '/api/1.0/games',
        queryParameters: {'title': query, 'limit': 1},
      );
      final results = response.data;
      if (results is! List || results.isEmpty || results.first is! Map) {
        await _writeDealCache(query, null);
        return null;
      }

      final raw = Map<String, dynamic>.from(results.first as Map);
      var deal = GameDeal.fromJson(raw);
      if (deal.isEmpty) {
        await _writeDealCache(query, null);
        return null;
      }

      final dealId = '${raw['cheapestDealID'] ?? ''}'.trim();
      deal = await _enrichWithStores(deal.copyWith(cheapestDealID: dealId));

      await _writeDealCache(query, deal);
      return deal;
    } catch (_) {
      return null;
    }
  }

  Future<GameDeal> _enrichWithStores(GameDeal deal) async {
    final stores = await _storesById();
    try {
      final response = await _dio.get<dynamic>(
        '/api/1.0/games',
        queryParameters: {'id': deal.gameID},
      );
      final data = response.data;
      if (data is! Map) {
        return deal;
      }
      final rawDeals = data['deals'];
      if (rawDeals is! List || rawDeals.isEmpty) {
        return deal;
      }

      final cheapest = _asPrice(deal.cheapestPrice);
      final cheapestStores = <String>[];
      final listedStores = <String>{};
      final offers = <StoreOffer>[];
      for (final item in rawDeals) {
        if (item is! Map) {
          continue;
        }
        final storeId = '${item['storeID'] ?? ''}'.trim();
        final name = stores[storeId] ?? '';
        if (name.isEmpty) {
          continue;
        }
        listedStores.add(name);
        final rawPrice = '${item['price'] ?? ''}'.trim();
        final price = _asPrice(rawPrice);
        final retail = _asPrice('${item['retailPrice'] ?? ''}');
        final dealId = '${item['dealID'] ?? item['dealId'] ?? ''}'.trim();
        final onSale = retail <= 0 || price < retail;
        if (onSale && dealId.isNotEmpty) {
          offers.add(
            StoreOffer(
              storeName: name,
              dealId: dealId,
              price: rawPrice.isEmpty ? deal.cheapestPrice : rawPrice,
            ),
          );
        }
        if (cheapest <= 0 || (price - cheapest).abs() > 0.02) {
          continue;
        }
        if (!cheapestStores.contains(name)) {
          cheapestStores.add(name);
        }
      }

      offers.sort((a, b) => _asPrice(a.price).compareTo(_asPrice(b.price)));

      if (cheapestStores.isEmpty && deal.cheapestDealID.isNotEmpty) {
        final fallback = await _storeNameForDeal(deal.cheapestDealID);
        if (fallback.isNotEmpty) {
          return deal.copyWith(
            storeName: fallback,
            storeNames: [fallback],
            offers: [
              StoreOffer(
                storeName: fallback,
                dealId: deal.cheapestDealID,
                price: deal.cheapestPrice,
              ),
            ],
          );
        }
      }

      final inAllStores =
          listedStores.length >= 2 &&
          cheapestStores.length == listedStores.length;

      return deal.copyWith(
        storeNames: cheapestStores,
        storeName: cheapestStores.isEmpty
            ? deal.storeName
            : cheapestStores.first,
        inAllStores: inAllStores,
        offers: offers,
      );
    } catch (_) {
      return deal;
    }
  }

  double _asPrice(String raw) {
    return double.tryParse(raw.replaceAll(',', '.')) ?? 0;
  }

  Future<String> _storeNameForDeal(String dealId) async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/1.0/deals',
        queryParameters: {'id': dealId},
      );
      final data = response.data;
      if (data is! Map) {
        return '';
      }
      final info = data['gameInfo'];
      if (info is! Map) {
        return '';
      }
      final storeId = '${info['storeID'] ?? ''}'.trim();
      if (storeId.isEmpty) {
        return '';
      }
      return _storeName(storeId);
    } catch (_) {
      return '';
    }
  }

  Future<String> _storeName(String storeId) async {
    final stores = await _storesById();
    return stores[storeId] ?? '';
  }

  Future<Map<String, String>> _storesById() async {
    final cached = _readStoresCache();
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    try {
      final response = await _dio.get<dynamic>('/api/1.0/stores');
      final raw = response.data;
      if (raw is! List) {
        return const {};
      }
      final stores = <String, String>{};
      for (final item in raw) {
        if (item is! Map) {
          continue;
        }
        final id = '${item['storeID'] ?? ''}'.trim();
        final name = (item['storeName'] as String?)?.trim() ?? '';
        if (id.isEmpty || name.isEmpty) {
          continue;
        }
        stores[id] = name;
      }
      await _writeStoresCache(stores);
      return stores;
    } catch (_) {
      return const {};
    }
  }

  GameDeal? _readDealCache(String title) {
    final box = _cache;
    if (box == null || !box.isOpen) {
      return null;
    }
    final raw = box.get(_dealKey(title));
    if (raw is! Map) {
      return null;
    }
    final cachedAt = raw['cachedAt'] as int?;
    if (cachedAt == null) {
      return null;
    }
    if (DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(cachedAt),
        ) >=
        _dealTtl) {
      return null;
    }
    if (raw['empty'] == true) {
      return const GameDeal(gameID: '', cheapestPrice: '', externalTitle: '');
    }
    final json = raw['deal'];
    if (json is! Map) {
      return null;
    }
    return GameDeal.fromJson(Map<String, dynamic>.from(json));
  }

  Future<void> _writeDealCache(String title, GameDeal? deal) async {
    final box = _cache;
    if (box == null || !box.isOpen) {
      return;
    }
    await box.put(_dealKey(title), {
      'cachedAt': DateTime.now().millisecondsSinceEpoch,
      'empty': deal == null,
      if (deal != null) 'deal': deal.toJson(),
    });
  }

  Map<String, String>? _readStoresCache() {
    final box = _cache;
    if (box == null || !box.isOpen) {
      return null;
    }
    final raw = box.get(_storesKey);
    if (raw is! Map) {
      return null;
    }
    final cachedAt = raw['cachedAt'] as int?;
    if (cachedAt == null) {
      return null;
    }
    if (DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(cachedAt),
        ) >=
        _storesTtl) {
      return null;
    }
    final items = raw['items'];
    if (items is! Map) {
      return null;
    }
    return {
      for (final entry in items.entries) '${entry.key}': '${entry.value}',
    };
  }

  Future<void> _writeStoresCache(Map<String, String> stores) async {
    final box = _cache;
    if (box == null || !box.isOpen) {
      return;
    }
    await box.put(_storesKey, {
      'cachedAt': DateTime.now().millisecondsSinceEpoch,
      'items': stores,
    });
  }

  String _dealKey(String title) {
    final normalized = title.trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    return 'deal_v4_$normalized';
  }
}
