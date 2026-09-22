import 'package:equatable/equatable.dart';

class StoreOffer extends Equatable {
  const StoreOffer({
    required this.storeName,
    required this.dealId,
    required this.price,
  });

  final String storeName;
  final String dealId;
  final String price;

  String get url => 'https://www.cheapshark.com/redirect?dealID=$dealId';

  factory StoreOffer.fromJson(Map<String, dynamic> json) {
    return StoreOffer(
      storeName: (json['storeName'] as String?)?.trim() ?? '',
      dealId: '${json['dealId'] ?? json['dealID'] ?? ''}'.trim(),
      price: '${json['price'] ?? ''}',
    );
  }

  Map<String, dynamic> toJson() {
    return {'storeName': storeName, 'dealId': dealId, 'price': price};
  }

  bool get isValid => dealId.isNotEmpty;

  @override
  List<Object?> get props => [storeName, dealId, price];
}

class GameDeal extends Equatable {
  const GameDeal({
    required this.gameID,
    required this.cheapestPrice,
    required this.externalTitle,
    this.storeName = '',
    this.cheapestDealID = '',
    this.storeNames = const [],
    this.inAllStores = false,
    this.offers = const [],
  });

  final String gameID;
  final String cheapestPrice;
  final String externalTitle;
  final String storeName;
  final String cheapestDealID;
  final List<String> storeNames;
  final bool inAllStores;
  final List<StoreOffer> offers;

  List<StoreOffer> get openableOffers {
    final valid = [
      for (final offer in offers)
        if (offer.isValid) offer,
    ];
    if (valid.isNotEmpty) {
      return valid;
    }
    if (cheapestDealID.isEmpty) {
      return const [];
    }
    return [
      StoreOffer(
        storeName: storeLabel.isEmpty ? 'Oferta' : storeLabel,
        dealId: cheapestDealID,
        price: cheapestPrice,
      ),
    ];
  }

  String get storeLabel {
    if (inAllStores) {
      return 'En todas';
    }
    if (storeNames.length >= 3) {
      return '${storeNames[0]}, ${storeNames[1]} y ${storeNames[2]}';
    }
    if (storeNames.length == 2) {
      return '${storeNames[0]} y ${storeNames[1]}';
    }
    if (storeNames.isNotEmpty) {
      return storeNames.first;
    }
    if (storeName.isNotEmpty) {
      return storeName;
    }
    return '';
  }

  String get detailsSubtitle {
    if (inAllStores) {
      return 'En descuento en todas las tiendas';
    }
    if (storeLabel.isNotEmpty) {
      return 'En descuento en $storeLabel';
    }
    return 'Mejor precio encontrado';
  }

  String get label {
    if (storeLabel.isNotEmpty) {
      return 'Oferta: \$$cheapestPrice · $storeLabel';
    }
    return 'Oferta: \$$cheapestPrice';
  }

  bool get isEmpty => gameID.isEmpty || cheapestPrice.isEmpty;

  factory GameDeal.fromJson(Map<String, dynamic> json) {
    final stores =
        (json['storeNames'] as List<dynamic>?)
            ?.map((item) => '$item')
            .where((item) => item.isNotEmpty)
            .toList() ??
        const <String>[];
    final offers =
        (json['offers'] as List<dynamic>?)
            ?.whereType<Map>()
            .map((item) => StoreOffer.fromJson(Map<String, dynamic>.from(item)))
            .where((item) => item.isValid)
            .toList() ??
        const <StoreOffer>[];
    return GameDeal(
      gameID: '${json['gameID'] ?? ''}',
      cheapestPrice: '${json['cheapest'] ?? json['salePrice'] ?? ''}',
      externalTitle:
          (json['external'] as String?)?.trim() ??
          (json['externalTitle'] as String?)?.trim() ??
          '',
      storeName: (json['storeName'] as String?)?.trim() ?? '',
      cheapestDealID: '${json['cheapestDealID'] ?? ''}',
      storeNames: stores,
      inAllStores: json['inAllStores'] == true,
      offers: offers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gameID': gameID,
      'cheapest': cheapestPrice,
      'external': externalTitle,
      'storeName': storeName,
      'cheapestDealID': cheapestDealID,
      'storeNames': storeNames,
      'inAllStores': inAllStores,
      'offers': [for (final offer in offers) offer.toJson()],
    };
  }

  GameDeal copyWith({
    String? storeName,
    String? cheapestDealID,
    List<String>? storeNames,
    bool? inAllStores,
    List<StoreOffer>? offers,
  }) {
    return GameDeal(
      gameID: gameID,
      cheapestPrice: cheapestPrice,
      externalTitle: externalTitle,
      storeName: storeName ?? this.storeName,
      cheapestDealID: cheapestDealID ?? this.cheapestDealID,
      storeNames: storeNames ?? this.storeNames,
      inAllStores: inAllStores ?? this.inAllStores,
      offers: offers ?? this.offers,
    );
  }

  @override
  List<Object?> get props => [
    gameID,
    cheapestPrice,
    externalTitle,
    storeName,
    cheapestDealID,
    storeNames,
    inAllStores,
    offers,
  ];
}
