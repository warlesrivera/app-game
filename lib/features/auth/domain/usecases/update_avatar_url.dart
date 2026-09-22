import '../repositories/auth_repository.dart';

class UpdateAvatarUrl {
  const UpdateAvatarUrl(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String uid,
    required String avatarUrl,
  }) {
    return _repository.updateAvatarUrl(uid: uid, avatarUrl: avatarUrl);
  }
}
