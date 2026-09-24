import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';

import '../../../app/firebase/firebase_initializer.dart';
import 'datasources/cheapshark_remote_datasource.dart';
import 'price_notification_service.dart';
import 'wishlist_price_snapshot.dart';

const priceWatchTask = 'priceWatchDaily';
const _priceWatchUnique = 'gamevault-price-watch';

@pragma('vm:entry-point')
void priceWatchDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != priceWatchTask) {
      return true;
    }
    try {
      await _runPriceWatch();
    } catch (error, stack) {
      debugPrint('Price watch: $error\n$stack');
      return false;
    }
    return true;
  });
}

Future<void> registerPriceWatch() async {
  await Workmanager().initialize(priceWatchDispatcher);
  await Workmanager().registerPeriodicTask(
    _priceWatchUnique,
    priceWatchTask,
    frequency: const Duration(hours: 24),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    constraints: Constraints(networkType: NetworkType.connected),
  );
}

Future<void> _runPriceWatch() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}
  await initializeFirebase();
  await Hive.initFlutter();
  final box = Hive.isBoxOpen(WishlistPriceSnapshot.boxName)
      ? Hive.box<dynamic>(WishlistPriceSnapshot.boxName)
      : await Hive.openBox<dynamic>(WishlistPriceSnapshot.boxName);
  final snapshot = WishlistPriceSnapshot(box);
  final watched = snapshot.read();
  if (watched.isEmpty) {
    return;
  }

  final deals = CheapSharkRemoteDataSource();
  final notifications = PriceNotificationService();
  await notifications.init();

  for (final item in watched) {
    final deal = await deals.searchByTitle(item.name);
    final price = double.tryParse(deal?.cheapestPrice ?? '');
    if (price == null) {
      continue;
    }
    final previous = item.lastPrice;
    if (previous != null && price < previous - 0.009) {
      await notifications.showPriceDrop(
        gameName: item.name,
        price: deal!.cheapestPrice,
      );
    }
    await snapshot.updatePrice(id: item.id, price: price);
  }
}
