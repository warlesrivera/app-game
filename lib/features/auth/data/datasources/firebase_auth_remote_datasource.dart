import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/errors/failures.dart';
import 'auth_remote_datasource.dart';

class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  FirebaseAuthRemoteDataSource({
    firebase_auth.FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  }) : _authOverride = auth,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final firebase_auth.FirebaseAuth? _authOverride;
  final GoogleSignIn _googleSignIn;
  Future<void>? _googleInit;

  firebase_auth.FirebaseAuth get _auth {
    if (_authOverride != null) {
      return _authOverride;
    }
    if (Firebase.apps.isEmpty) {
      throw const AuthFailure(
        'not-configured',
        'Firebase no está configurado todavía.',
      );
    }
    return firebase_auth.FirebaseAuth.instance;
  }

  @override
  Stream<firebase_auth.User?> watchFirebaseUser() {
    if (Firebase.apps.isEmpty && _authOverride == null) {
      return Stream<firebase_auth.User?>.value(null);
    }
    return _auth.authStateChanges();
  }

  @override
  Future<firebase_auth.User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _requireUser(credential.user);
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw _mapAuthException(error);
    }
  }

  @override
  Future<firebase_auth.User> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = _requireUser(credential.user);
      await user.updateDisplayName(name);
      return user;
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw _mapAuthException(error);
    }
  }

  @override
  Future<firebase_auth.User> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = firebase_auth.GoogleAuthProvider()
          ..addScope('email')
          ..setCustomParameters({'prompt': 'select_account'});
        final credential = await _auth.signInWithPopup(provider);
        return _requireUser(credential.user);
      }

      await _ensureGoogleInitialized();
      final googleUser = await _googleSignIn.authenticate();
      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw const AuthFailure(
          'missing-id-token',
          'Google no devolvió un token válido.',
        );
      }

      final credential = await _auth.signInWithCredential(
        firebase_auth.GoogleAuthProvider.credential(idToken: idToken),
      );
      return _requireUser(credential.user);
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw _mapAuthException(error);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthCancelled();
      }
      throw AuthFailure(
        error.code.name,
        error.description ?? 'No se pudo iniciar sesión con Google.',
      );
    }
  }

  @override
  Future<void> signOut() async {
    if (Firebase.apps.isNotEmpty || _authOverride != null) {
      await _auth.signOut();
    }
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Puede fallar si Google Sign-In no se inicializó.
    }
  }

  Future<void> _ensureGoogleInitialized() {
    return _googleInit ??= _googleSignIn.initialize();
  }

  firebase_auth.User _requireUser(firebase_auth.User? user) {
    if (user == null) {
      throw const AuthFailure(
        'user-null',
        'Firebase no devolvió un usuario autenticado.',
      );
    }
    return user;
  }

  AuthFailure _mapAuthException(firebase_auth.FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return const AuthFailure('invalid-email', 'El email no es válido.');
      case 'user-disabled':
        return const AuthFailure('user-disabled', 'Esta cuenta está deshabilitada.');
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const AuthFailure(
          'invalid-credential',
          'Email o contraseña incorrectos.',
        );
      case 'email-already-in-use':
        return const AuthFailure(
          'email-already-in-use',
          'Este email ya está registrado.',
        );
      case 'weak-password':
        return const AuthFailure(
          'weak-password',
          'La contraseña es demasiado débil.',
        );
      case 'network-request-failed':
        return const AuthFailure(
          'network-request-failed',
          'Sin conexión. Inténtalo de nuevo.',
        );
      case 'operation-not-allowed':
        return const AuthFailure(
          'operation-not-allowed',
          'Este método de acceso no está habilitado.',
        );
      default:
        return AuthFailure(
          error.code,
          'No se pudo completar la autenticación.',
        );
    }
  }
}
