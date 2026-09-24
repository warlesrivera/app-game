import '../../../ai_chat/data/datasources/advisor_reply_cache.dart';
import '../../domain/models/gaming_models.dart';
import '../../domain/repositories/gaming_advisor_repository.dart';
import '../datasources/gaming_advisor_remote_datasource.dart';

class GamingAdvisorRepositoryImpl implements GamingAdvisorRepository {
  GamingAdvisorRepositoryImpl({
    required GamingAdvisorRemoteDataSource remote,
    required AdvisorReplyCache cache,
  }) : _remote = remote,
       _cache = cache;

  final GamingAdvisorRemoteDataSource _remote;
  final AdvisorReplyCache _cache;

  @override
  Future<void> clearMessages() => _remote.clearMessages();

  @override
  Future<void> deleteMemory(String id) => _remote.deleteMemory(id);

  @override
  Future<List<GameExperience>> getExperiences() => _remote.getExperiences();

  @override
  Future<List<GamingMemory>> getMemories() => _remote.getMemories();

  @override
  Future<List<AdvisorMessage>> getMessages() => _remote.getMessages();

  @override
  Future<GamingProfile> getProfile() => _remote.getProfile();

  @override
  String? readCachedReply(String key) => _cache.read('ga:$key');

  @override
  Future<void> saveExperience(GameExperience experience) {
    return _remote.saveExperience(experience);
  }

  @override
  Future<void> saveMemory(GamingMemory memory) => _remote.saveMemory(memory);

  @override
  Future<void> saveMessage(AdvisorMessage message) => _remote.saveMessage(message);

  @override
  Future<void> saveProfile(GamingProfile profile) => _remote.saveProfile(profile);

  @override
  Future<void> writeCachedReply(String key, String text) {
    return _cache.write('ga:$key', text);
  }
}
