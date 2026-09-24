import '../models/gaming_models.dart';

abstract interface class GamingAdvisorRepository {
  Future<GamingProfile> getProfile();

  Future<void> saveProfile(GamingProfile profile);

  Future<List<GamingMemory>> getMemories();

  Future<void> saveMemory(GamingMemory memory);

  Future<void> deleteMemory(String id);

  Future<void> saveExperience(GameExperience experience);

  Future<List<GameExperience>> getExperiences();

  Future<List<AdvisorMessage>> getMessages();

  Future<void> saveMessage(AdvisorMessage message);

  Future<void> clearMessages();

  String? readCachedReply(String key);

  Future<void> writeCachedReply(String key, String text);
}

abstract interface class AIAdvisorService {
  Future<String> ask({required String systemInstruction, required String prompt});

  bool get isAvailable;
}
