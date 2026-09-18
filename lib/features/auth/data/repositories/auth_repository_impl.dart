import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/user_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.authDataSource,
    required this.userDataSource,
  });

  final AuthRemoteDataSource authDataSource;
  final UserRemoteDataSource userDataSource;

  @override
  Stream<AppUser?> watchAuthState() {
    return authDataSource.watchFirebaseUser().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }
      return _ensureProfile(firebaseUser);
    });
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final user = await authDataSource.signInWithEmail(
      email: email,
      password: password,
    );
    await _ensureProfile(user);
  }

  @override
  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final user = await authDataSource.signUpWithEmail(
      name: name,
      email: email,
      password: password,
    );
    await _ensureProfile(user, fallbackName: name);
  }

  @override
  Future<void> signInWithGoogle() async {
    final user = await authDataSource.signInWithGoogle();
    await _ensureProfile(user);
  }

  @override
  Future<void> signOut() => authDataSource.signOut();

  Future<AppUser> _ensureProfile(
    firebase_auth.User firebaseUser, {
    String? fallbackName,
  }) {
    return userDataSource.ensureProfile(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: _resolveName(firebaseUser, fallbackName: fallbackName),
    );
  }

  String _resolveName(
    firebase_auth.User firebaseUser, {
    String? fallbackName,
  }) {
    final explicit = fallbackName?.trim();
    if (explicit != null && explicit.isNotEmpty) {
      return explicit;
    }
    final displayName = firebaseUser.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    final email = firebaseUser.email ?? '';
    if (email.contains('@')) {
      return email.split('@').first;
    }
    return 'Player';
  }
}
