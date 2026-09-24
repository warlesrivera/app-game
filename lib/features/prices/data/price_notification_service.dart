import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PriceNotificationService {
  PriceNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const channelId = 'price_alerts';
  static const channelName = 'Ofertas de precio';

  final FlutterLocalNotificationsPlugin _plugin;
  var _ready = false;

  Future<void> init() async {
    if (_ready || kIsWeb) {
      return;
    }
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _ready = true;
  }

  Future<void> requestPermission() async {
    if (kIsWeb) {
      return;
    }
    await init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> showPriceDrop({
    required String gameName,
    required String price,
  }) async {
    await init();
    final id = gameName.hashCode & 0x7fffffff;
    await _plugin.show(
      id,
      'Oferta',
      '$gameName ha bajado a \$$price',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: 'Avisos cuando un juego de la wishlist baja de precio',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
