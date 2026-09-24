import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../features/auth/presentation/cubit/auth_cubit.dart';
import 'app.dart';
import 'di/injection.dart';
import 'firebase/firebase_initializer.dart';
import 'theme/app_theme.dart';
import '../features/prices/data/price_notification_service.dart';
import '../features/prices/data/price_watch_worker.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(AppTheme.systemUi);

  await initializeFirebase();
  await Hive.initFlutter();
  await configureDependencies();
  await getIt<PriceNotificationService>().requestPermission();
  await registerPriceWatch();

  runApp(GameVaultApp(authCubit: getIt<AuthCubit>()));
}
