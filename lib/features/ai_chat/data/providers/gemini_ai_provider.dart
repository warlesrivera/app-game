import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../domain/ai_error.dart';
import '../../domain/models/advisor_limits.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/game_ai_context.dart';
import '../../domain/models/player_vault_context.dart';

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
    PlayerVaultContext? vault,
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
          vault: vault,
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
    PlayerVaultContext? vault,
    required List<ChatMessage> history,
  }) async {
    final label = gameContext?.systemLine ?? gameName;
    final vaultLine = vault != null && vault.hasLibrary
        ? ' Bóveda: ${vault.compactLine}.'
        : '';
    final model = GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        maxOutputTokens: AdvisorLimits.maxOutputTokens,
        temperature: 0.4,
        topP: 0.9,
      ),
      systemInstruction: Content.system(
        'Asesor GameVault. Español, 2-6 frases. '
        'Juego: $label.$vaultLine '
        'Usa solo este contexto. No inventes gustos ni spoilers graves. '
        'No repitas la ficha ni el perfil.',
      ),
    );

    final chat = model.startChat(
      history: _historyContents(gameContext, history),
    );
    final response = await _withRetry(
      () => chat.sendMessage(
        Content.text(
          clipText(message, AdvisorLimits.maxQuestionChars) ?? message,
        ),
      ),
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
    final recent = history.length <= AdvisorLimits.maxRecentMessages
        ? history
        : history.sublist(history.length - AdvisorLimits.maxRecentMessages);

    if (recent.isEmpty) {
      final brief = gameContext?.firstTurnBrief;
      if (brief != null) {
        contents
          ..add(Content.text('Ficha (no la repitas): $brief'))
          ..add(Content.model([TextPart('Entendido. Pregunta.')]));
      }
    } else {
      for (final item in recent) {
        final text = clipText(item.text, AdvisorLimits.maxHistoryChars);
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

  Future<String?> generatePlayerProfile({
    required int completed,
    required int abandoned,
    required int playing,
    required String favoriteGenre,
    required List<String> topFavorites,
    required Map<String, int> genreCounts,
  }) {
    if (!isAvailable) {
      return Future<String?>.value(null);
    }

    final favorites = topFavorites.isEmpty
        ? 'sin podio todavía'
        : topFavorites
              .asMap()
              .entries
              .map((entry) {
                return '${entry.key + 1}.º ${entry.value}';
              })
              .join(', ');
    final genres = (genreCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .where((entry) => entry.value > 0)
        .take(4)
        .map((entry) => '${entry.key}:${entry.value}')
        .join(',');

    return _generatePlain(
      system:
          'Analista de videojuegos. SOLO JSON en español, sin markdown: '
          '"title" (corto), "summary" (máx 2 líneas), '
          '"details" (1 o 2 párrafos: por qué, con favoritos y ritmo).',
      prompt:
          'Perfil: $completed ok, $playing jugando, $abandoned off. '
          'Género: $favoriteGenre. Top: ${genres.isEmpty ? '-' : genres}. '
          'Fav: $favorites.',
    );
  }

  Future<String> advise({
    required String systemInstruction,
    required String prompt,
  }) async {
    if (!isAvailable) {
      throw StateError('Gemini no está configurado.');
    }
    final text = await _generatePlain(system: systemInstruction, prompt: prompt);
    if (text == null || text.isEmpty) {
      throw StateError('No pude consultar el asistente ahora.');
    }
    return text;
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
