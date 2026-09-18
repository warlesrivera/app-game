import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:gamevault/firebase_options.dart';

Future<void> initializeFirebase() async {
  if (Firebase.apps.isNotEmpty) {
    _enableOfflinePersistence();
    return;
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _enableOfflinePersistence();
    _attachCrashlytics();
  } catch (error, stackTrace) {
    debugPrint('Firebase no pudo inicializarse.\n$error\n$stackTrace');
  }
}

void _enableOfflinePersistence() {
  if (Firebase.apps.isEmpty) {
    return;
  }
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  } catch (_) {
    // Settings solo se puede asignar una vez por proceso.
  }
}

void _attachCrashlytics() {
  if (kIsWeb || Firebase.apps.isEmpty) {
    return;
  }

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}
