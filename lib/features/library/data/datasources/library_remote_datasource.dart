import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/models/library_entry.dart';
import '../../domain/models/library_status.dart';

class LibraryRemoteDataSource {
  LibraryRemoteDataSource({
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

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw const AuthFailure('unauthenticated', 'Inicia sesión para continuar.');
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _games {
    return _firestore.collection('users').doc(_uid).collection('games');
  }

  Stream<List<LibraryEntry>> watchEntries() {
    if (Firebase.apps.isEmpty && _firestoreOverride == null) {
      return Stream.value(const []);
    }
    if (_auth.currentUser == null) {
      return Stream.value(const []);
    }

    return _games.snapshots().map((snapshot) {
      return snapshot.docs.map(_fromDoc).toList();
    });
  }

  Future<LibraryEntry?> getEntry(String gameId) async {
    if (_auth.currentUser == null) {
      return null;
    }
    final doc = await _games.doc(gameId).get();
    if (!doc.exists) {
      return null;
    }
    return _fromDoc(doc);
  }

  Future<void> setStatus({
    required String gameId,
    required LibraryStatus status,
  }) {
    return _games.doc(gameId).set({
      'status': status.firestoreValue,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removeGame(String gameId) {
    return _games.doc(gameId).delete();
  }

  Future<void> setPriceAlert({
    required String gameId,
    required bool enabled,
    required List<String> stores,
  }) {
    return _games.doc(gameId).set({
      'priceAlerts': enabled,
      'targetStores': stores,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  LibraryEntry _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final updatedAt = data['updatedAt'];
    return LibraryEntry(
      gameId: doc.id,
      status: LibraryStatus.tryParse(data['status'] as String?) ??
          LibraryStatus.wishlist,
      personalRating: (data['personalRating'] as num?)?.toDouble(),
      notes: data['notes'] as String?,
      updatedAt: updatedAt is Timestamp ? updatedAt.toDate() : null,
      priceAlerts: data['priceAlerts'] as bool? ?? false,
      targetStores: (data['targetStores'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const [],
    );
  }
}
