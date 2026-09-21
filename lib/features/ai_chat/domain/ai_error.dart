String friendlyAiError(Object error) {
  if (error is StateError) {
    final message = error.message.trim();
    if (message.isNotEmpty &&
        !message.contains('GenerativeAIException') &&
        !message.contains('"error"') &&
        message != 'Gemini no está configurado.') {
      return message;
    }
  }
  final text = error.toString().toLowerCase();
  if (text.contains('503') ||
      text.contains('unavailable') ||
      text.contains('high demand')) {
    return 'Gemini está ocupado ahora. Espera unos segundos e inténtalo de nuevo.';
  }
  if (text.contains('429') || text.contains('resource exhausted')) {
    return 'Hay muchas consultas ahora. Espera un momento y vuelve a intentar.';
  }
  if (text.contains('api key') || text.contains('401') || text.contains('403')) {
    return 'La clave de Gemini no es válida. Revisa GEMINI_API_KEY.';
  }
  return 'No se pudo responder ahora. Inténtalo de nuevo.';
}
