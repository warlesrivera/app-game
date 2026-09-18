import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiAiProvider {
  GeminiAiProvider({required String apiKey}) : _apiKey = apiKey.trim();

  final String _apiKey;

  bool get isAvailable => _apiKey.isNotEmpty;

  Future<String> generate({
    required String gameName,
    required String message,
  }) async {
    if (!isAvailable) {
      throw StateError('Gemini no está configurado.');
    }

    final model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(
        'Eres el asistente de GameVault. Habla en español, de forma breve y útil. '
        'El usuario pregunta sobre el videojuego "$gameName". '
        'No inventes spoilers graves si no te los piden.',
      ),
    );

    final response = await model.generateContent([Content.text(message)]);
    final text = response.text?.trim();
    if (text == null || text.isEmpty) {
      return 'No pude generar una respuesta ahora. Inténtalo de nuevo.';
    }
    return text;
  }
}
