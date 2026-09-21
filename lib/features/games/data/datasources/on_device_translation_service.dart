import 'package:flutter/foundation.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../../domain/repositories/game_translator.dart';

class OnDeviceTranslationService implements GameTranslator {
  OnDeviceTranslationService();

  final _manager = OnDeviceTranslatorModelManager();
  OnDeviceTranslator? _translator;
  Future<void>? _ready;

  @override
  Future<String?> translateToSpanish(String text) async {
    final source = text.trim();
    if (source.isEmpty) {
      return null;
    }

    try {
      await _ensureReady();
      final translator = _translator;
      if (translator == null) {
        return null;
      }

      final buffer = StringBuffer();
      for (final chunk in _chunks(source)) {
        final translated = (await translator.translateText(chunk)).trim();
        if (translated.isEmpty) {
          continue;
        }
        if (buffer.isNotEmpty) {
          buffer.write('\n\n');
        }
        buffer.write(translated);
      }
      final result = buffer.toString().trim();
      return result.isEmpty ? null : result;
    } catch (error) {
      debugPrint('On-device translate: $error');
      return null;
    }
  }

  Future<void> _ensureReady() {
    return _ready ??= _prepare();
  }

  Future<void> _prepare() async {
    try {
      await _manager.downloadModel(
        TranslateLanguage.english.bcpCode,
        isWifiRequired: false,
      );
      await _manager.downloadModel(
        TranslateLanguage.spanish.bcpCode,
        isWifiRequired: false,
      );
      _translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.english,
        targetLanguage: TranslateLanguage.spanish,
      );
    } catch (error) {
      _ready = null;
      rethrow;
    }
  }

  static List<String> _chunks(String text) {
    const max = 4000;
    if (text.length <= max) {
      return [text];
    }

    final chunks = <String>[];
    final paragraphs = text.split(RegExp(r'\n\s*\n'));
    final current = StringBuffer();
    for (final paragraph in paragraphs) {
      final piece = paragraph.trim();
      if (piece.isEmpty) {
        continue;
      }
      if (current.isNotEmpty && current.length + piece.length + 2 > max) {
        chunks.add(current.toString());
        current.clear();
      }
      if (current.isNotEmpty) {
        current.write('\n\n');
      }
      current.write(piece);
    }
    if (current.isNotEmpty) {
      chunks.add(current.toString());
    }
    return chunks.isEmpty ? [text.substring(0, max)] : chunks;
  }
}
