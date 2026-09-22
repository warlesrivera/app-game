import '../entities/app_user.dart';

abstract interface class AuthRepository {
  Stream<AppUser?> watchAuthState();

  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signInWithGoogle();

  Future<void> signOut();

  Future<void> updateAvatarUrl({
    required String uid,
    required String avatarUrl,
  });
}
