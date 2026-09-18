import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

abstract interface class AuthRemoteDataSource {
  Stream<firebase_auth.User?> watchFirebaseUser();

  Future<firebase_auth.User> signInWithEmail({
    required String email,
    required String password,
  });

  Future<firebase_auth.User> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<firebase_auth.User> signInWithGoogle();

  Future<void> signOut();
}
