import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CurrentConsoleCubit extends Cubit<String?> {
  CurrentConsoleCubit() : super(null) {
    emit(_read());
  }

  static const _key = 'current_console';

  Future<void> select(String slug) async {
    final next = state == slug ? null : slug;
    emit(next);
    final box = _box();
    if (box == null) {
      return;
    }
    if (next == null) {
      await box.delete(_key);
      return;
    }
    await box.put(_key, next);
  }

  String? _read() {
    final raw = _box()?.get(_key);
    return raw is String && raw.isNotEmpty ? raw : null;
  }

  Box<dynamic>? _box() {
    if (!Hive.isBoxOpen('game_cache')) {
      return null;
    }
    return Hive.box<dynamic>('game_cache');
  }
}
