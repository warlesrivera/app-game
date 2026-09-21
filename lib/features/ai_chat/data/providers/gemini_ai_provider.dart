import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../domain/ai_error.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/game_ai_context.dart';

class GeminiAiProvider {
  GeminiAiProvider({required String apiKey}) : _apiKey = apiKey.trim();

  final String _apiKey;

  static const _models = [
    'gemini-flash-lite-latest',
    'gemini-3.5-flash-lite',
    'gemini-3.1-flash-lite',
  ];

  bool get isAvailable => _apiKey.isNotEmpty;

  Future<String> generate({
    required String gameName,
    required String message,
    GameAiContext? gameContext,
    List<ChatMessage> history = const [],
  }) async {
    if (!isAvailable) {
      throw StateError('Gemini no está configurado.');
    }

    Object? lastError;
    for (final modelName in _models) {
      try {
        return await _generateWithModel(
          modelName: modelName,
          gameName: gameName,
          message: message,
          gameContext: gameContext,
          history: history,
        );
      } catch (error) {
        lastError = error;
        debugPrint('Gemini $modelName: $error');
        if (!_shouldTryNextModel(error)) {
          throw StateError(friendlyAiError(error));
        }
      }
    }

    throw StateError(friendlyAiError(lastError ?? 'UNAVAILABLE'));
  }

  Future<String> _generateWithModel({
    required String modelName,
    required String gameName,
    required String message,
    GameAiContext? gameContext,
    required List<ChatMessage> history,
  }) async {
    final label = gameContext?.systemLine ?? gameName;
    final model = GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
      systemInstruction: Content.system(
        'Eres el asistente de GameVault. Español, breve y útil. '
        'Juego: $label. No inventes spoilers graves si no te los piden. '
        'Reutiliza la ficha y el historial; no repitas la sinopsis.',
      ),
    );

    final chat = model.startChat(history: _historyContents(gameContext, history));
    final response = await _withRetry(
      () => chat.sendMessage(Content.text(clipText(message, 1000) ?? message)),
    );
    final text = response.text?.trim();
    if (text == null || text.isEmpty) {
      return 'No pude generar una respuesta ahora. Inténtalo de nuevo.';
    }
    return text;
  }

  List<Content> _historyContents(
    GameAiContext? gameContext,
    List<ChatMessage> history,
  ) {
    final contents = <Content>[];
    final recent = history.length <= 6
        ? history
        : history.sublist(history.length - 6);

    if (recent.isEmpty) {
      final brief = gameContext?.firstTurnBrief;
      if (brief != null) {
        contents
          ..add(Content.text('Ficha (no la repitas): $brief'))
          ..add(Content.model([TextPart('Entendido. Pregunta.')]));
      }
    } else {
      for (final item in recent) {
        final text = clipText(item.text, 500);
        if (text == null) {
          continue;
        }
        if (item.isUser) {
          contents.add(Content.text(text));
        } else {
          contents.add(Content.model([TextPart(text)]));
        }
      }
      while (contents.isNotEmpty && contents.first.role != 'user') {
        contents.removeAt(0);
      }
      while (contents.isNotEmpty && contents.last.role == 'user') {
        contents.removeLast();
      }
    }

    return contents;
  }

  Future<T> _withRetry<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error) {
      if (!_isTransient(error)) {
        rethrow;
      }
      await Future<void>.delayed(const Duration(milliseconds: 700));
      return action();
    }
  }

  Future<String?> translateToSpanish(String text) async {
    if (!isAvailable) {
      return null;
    }

    final clipped = text.length > 4500 ? text.substring(0, 4500) : text;
    return _generatePlain(
      system:
          'Traduce al español natural (neutro latinoamericano). '
          'Devuelve solo la traducción, sin comillas, títulos ni notas.',
      prompt: clipped,
    );
  }

  Future<String?> generateStarterGuide(String gameName) async {
    if (!isAvailable) {
      return null;
    }

    return _generatePlain(
      system:
          'Eres un guía de videojuegos. Escribe en español, breve y sin spoilers graves. '
          'Incluye cómo empezar, consejos útiles y sistemas principales. Máximo 220 palabras.',
      prompt: 'Guía de inicio para "$gameName".',
    );
  }

  Future<String?> _generatePlain({
    required String system,
    required String prompt,
  }) async {
    for (final modelName in _models) {
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: _apiKey,
          systemInstruction: Content.system(system),
        );
        final response = await _withRetry(
          () => model.generateContent([Content.text(prompt)]),
        );
        final text = response.text?.trim();
        if (text != null && text.isNotEmpty) {
          return text;
        }
      } catch (error) {
        debugPrint('Gemini $modelName: $error');
        if (!_shouldTryNextModel(error)) {
          return null;
        }
      }
    }
    return null;
  }

  static bool _isTransient(Object error) {
    final text = error.toString().toLowerCase();
    if (text.contains('no longer available') || text.contains('not found')) {
      return false;
    }
    return text.contains('503') ||
        text.contains('unavailable') ||
        text.contains('high demand');
  }

  static bool _shouldTryNextModel(Object error) {
    final text = error.toString().toLowerCase();
    return _isTransient(error) ||
        text.contains('404') ||
        text.contains('not found') ||
        text.contains('no longer available') ||
        text.contains('not supported') ||
        text.contains('429') ||
        text.contains('resource exhausted') ||
        text.contains('quota');
  }
}
