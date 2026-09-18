import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_user.dart';
import '../models/app_user_model.dart';
import 'user_remote_datasource.dart';

class FirestoreUserRemoteDataSource implements UserRemoteDataSource {
  FirestoreUserRemoteDataSource({FirebaseFirestore? firestore})
    : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  static const String _usersCollection = 'users';
  static const String _tempAvatarId = 'avatar_01';
  static const int _unsetAge = 0;

  FirebaseFirestore get _firestore {
    if (_firestoreOverride != null) {
      return _firestoreOverride;
    }
    if (Firebase.apps.isEmpty) {
      throw const AuthFailure(
        'not-configured',
        'Firebase no está configurado todavía.',
      );
    }
    return FirebaseFirestore.instance;
  }

  @override
  Future<AppUser> ensureProfile({
    required String uid,
    required String email,
    required String name,
  }) async {
    final doc = _firestore.collection(_usersCollection).doc(uid);
    final snapshot = await doc.get();

    if (snapshot.exists) {
      final data = snapshot.data() ?? <String, dynamic>{};
      return AppUserModel.fromMap(uid, data).toEntity();
    }

    // La contraseña NUNCA se persiste. Solo vive en Firebase Auth.
    await doc.set({
      'name': name,
      'email': email,
      'age': _unsetAge,
      'avatarId': _tempAvatarId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return AppUser(
      id: uid,
      email: email,
      name: name,
      age: _unsetAge,
      avatarId: _tempAvatarId,
    );
  }
}
