import '../../domain/entities/app_user.dart';

abstract interface class UserRemoteDataSource {
  Future<AppUser> ensureProfile({
    required String uid,
    required String email,
    required String name,
  });
}
