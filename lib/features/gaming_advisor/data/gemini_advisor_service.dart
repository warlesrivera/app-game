import '../../ai_chat/data/providers/gemini_ai_provider.dart';
import '../domain/repositories/gaming_advisor_repository.dart';

class GeminiAdvisorService implements AIAdvisorService {
  GeminiAdvisorService(this._provider);

  final GeminiAiProvider _provider;

  @override
  bool get isAvailable => _provider.isAvailable;

  @override
  Future<String> ask({
    required String systemInstruction,
    required String prompt,
  }) {
    return _provider.advise(systemInstruction: systemInstruction, prompt: prompt);
  }
}
