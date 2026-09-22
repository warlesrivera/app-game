import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/models/player_analysis.dart';

class PlayerAnalysisRemoteDataSource {
  PlayerAnalysisRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestoreOverride = firestore,
       _authOverride = auth;

  final FirebaseFirestore? _firestoreOverride;
  final FirebaseAuth? _authOverride;

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

  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;

  DocumentReference<Map<String, dynamic>>? get _doc {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return null;
    }
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('insights')
        .doc('player_analysis');
  }

  Future<PlayerAnalysis?> get() async {
    final doc = _doc;
    if (doc == null) {
      return null;
    }
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      return null;
    }
    final data = snapshot.data();
    if (data == null) {
      return null;
    }
    final analysis = PlayerAnalysis.fromJson(data);
    return analysis.hasContent ? analysis : null;
  }

  Future<void> save(PlayerAnalysis analysis) async {
    final doc = _doc;
    if (doc == null) {
      throw const AuthFailure(
        'unauthenticated',
        'Inicia sesión para continuar.',
      );
    }
    await doc.set({
      ...analysis.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
