/// Techos de contexto para no mandar la biblioteca entera a Gemini.
abstract final class AdvisorLimits {
  static const maxRelevantGames = 8;
  static const maxFavorites = 5;
  static const maxPerStatus = 3;
  static const maxRecentMessages = 4;
  static const maxHistoryChars = 280;
  static const maxQuestionChars = 800;
  static const maxSynopsisChars = 220;
  static const maxProfileHintChars = 160;
  static const maxOutputTokens = 320;
}
