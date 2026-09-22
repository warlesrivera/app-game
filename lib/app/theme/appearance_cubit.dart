import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app_colors.dart';
import 'app_palette.dart';

final class AppearanceState {
  const AppearanceState({
    this.mode = ThemeMode.system,
    this.presetId = 'gold',
    this.customAccent = AccentCatalog.gold,
  });

  final ThemeMode mode;
  final String presetId;
  final Color customAccent;

  bool get isCustom => presetId == AccentCatalog.customId;

  Color get accent {
    if (isCustom) {
      return customAccent;
    }
    return AccentCatalog.byId(presetId)?.color ?? AccentCatalog.gold;
  }

  AppPalette paletteFor(Brightness brightness) {
    final resolved = mode == ThemeMode.system
        ? brightness
        : (mode == ThemeMode.dark ? Brightness.dark : Brightness.light);
    return resolved == Brightness.dark
        ? AppPalette.dark(accent)
        : AppPalette.light(accent);
  }

  AppearanceState copyWith({
    ThemeMode? mode,
    String? presetId,
    Color? customAccent,
  }) {
    return AppearanceState(
      mode: mode ?? this.mode,
      presetId: presetId ?? this.presetId,
      customAccent: customAccent ?? this.customAccent,
    );
  }
}

class AppearanceCubit extends Cubit<AppearanceState> {
  AppearanceCubit({Box<dynamic>? cache})
    : _cache = cache,
      super(const AppearanceState()) {
    final loaded = _read();
    AppColors.bind(loaded.paletteFor(Brightness.dark));
    emit(loaded);
  }

  static const _key = 'appearance_v1';

  final Box<dynamic>? _cache;

  void applyBrightness(Brightness brightness) {
    AppColors.bind(state.paletteFor(brightness));
  }

  Future<void> setMode(ThemeMode mode) {
    return _commit(state.copyWith(mode: mode));
  }

  Future<void> setPreset(String presetId) {
    return _commit(state.copyWith(presetId: presetId));
  }

  Future<void> setCustomAccent(Color color) {
    return _commit(
      state.copyWith(presetId: AccentCatalog.customId, customAccent: color),
    );
  }

  Future<void> _commit(AppearanceState next) async {
    AppColors.bind(next.paletteFor(AppColors.palette.brightness));
    emit(next);
    await _write(next);
  }

  AppearanceState _read() {
    try {
      final box = _cache ?? _openBox();
      if (box == null) {
        return const AppearanceState();
      }
      final raw = box.get(_key);
      if (raw is! Map) {
        return const AppearanceState();
      }
      return AppearanceState(
        mode: _modeFrom((raw['mode'] as String?) ?? 'system'),
        presetId: (raw['presetId'] as String?) ?? 'gold',
        customAccent: Color(
          (raw['customAccent'] as int?) ?? AccentCatalog.gold.toARGB32(),
        ),
      );
    } catch (_) {
      return const AppearanceState();
    }
  }

  Future<void> _write(AppearanceState next) async {
    try {
      final box = _cache ?? _openBox();
      if (box == null) {
        return;
      }
      await box.put(_key, {
        'mode': next.mode.name,
        'presetId': next.presetId,
        'customAccent': next.customAccent.toARGB32(),
      });
    } catch (_) {}
  }

  Box<dynamic>? _openBox() {
    if (!Hive.isBoxOpen('game_cache')) {
      return null;
    }
    return Hive.box<dynamic>('game_cache');
  }

  static ThemeMode _modeFrom(String raw) {
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}
