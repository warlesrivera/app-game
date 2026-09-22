import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/models/library_entry.dart';
import '../../domain/models/library_status.dart';

class LibraryRemoteDataSource {
  LibraryRemoteDataSource({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestoreOverride = firestore,
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
      throw const AuthFailure(
        'unauthenticated',
        'Inicia sesión para continuar.',
      );
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
      if (status != LibraryStatus.completed) 'isFavorite': false,
      if (status != LibraryStatus.completed)
        'favoriteRank': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setFavorite({
    required String gameId,
    required bool isFavorite,
  }) async {
    final entry = await getEntry(gameId);
    if (entry == null || entry.status != LibraryStatus.completed) {
      throw const Failure(
        'favorite-locked',
        'Debes completar el juego para agregarlo a favoritos',
      );
    }
    final ordered = await _orderedFavoriteIds();
    if (isFavorite) {
      if (!ordered.contains(gameId)) {
        ordered.add(gameId);
      }
      await _writeFavoriteOrder(ordered);
      return;
    }

    ordered.remove(gameId);
    final batch = _firestore.batch();
    batch.set(_games.doc(gameId), {
      'isFavorite': false,
      'favoriteRank': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    _putFavoriteOrder(batch, ordered);
    await batch.commit();
  }

  Future<void> setFavoriteRank({required String gameId, int? rank}) async {
    final entry = await getEntry(gameId);
    if (entry == null || !entry.isFavorite || !entry.canBeFavorite) {
      throw const Failure(
        'favorite-rank-locked',
        'Solo puedes destacar juegos que ya estén en favoritos.',
      );
    }
    if (rank != null && rank < 1) {
      throw const Failure('invalid-rank', 'La posición no es válida.');
    }

    final ordered = await _orderedFavoriteIds();
    ordered.remove(gameId);
    if (rank == null) {
      ordered.add(gameId);
    } else {
      final index = (rank - 1).clamp(0, ordered.length);
      ordered.insert(index, gameId);
    }
    await _writeFavoriteOrder(ordered);
  }

  Future<void> setFavoriteOrder(List<String> gameIds) {
    return _writeFavoriteOrder(gameIds);
  }

  Future<List<String>> _orderedFavoriteIds() async {
    final snapshot = await _games.where('isFavorite', isEqualTo: true).get();
    final items =
        snapshot.docs.map(_fromDoc).where((entry) {
          return entry.canBeFavorite;
        }).toList()..sort((a, b) {
          final rankA = a.favoriteRank ?? 9999;
          final rankB = b.favoriteRank ?? 9999;
          if (rankA != rankB) {
            return rankA.compareTo(rankB);
          }
          return a.gameId.compareTo(b.gameId);
        });
    return [for (final item in items) item.gameId];
  }

  Future<void> _writeFavoriteOrder(List<String> gameIds) async {
    if (gameIds.isEmpty) {
      return;
    }
    final batch = _firestore.batch();
    _putFavoriteOrder(batch, gameIds);
    await batch.commit();
  }

  void _putFavoriteOrder(WriteBatch batch, List<String> gameIds) {
    for (var index = 0; index < gameIds.length; index += 1) {
      batch.set(_games.doc(gameIds[index]), {
        'isFavorite': true,
        'favoriteRank': index + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
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
      status:
          LibraryStatus.tryParse(data['status'] as String?) ??
          LibraryStatus.wishlist,
      personalRating: (data['personalRating'] as num?)?.toDouble(),
      notes: data['notes'] as String?,
      updatedAt: updatedAt is Timestamp ? updatedAt.toDate() : null,
      priceAlerts: data['priceAlerts'] as bool? ?? false,
      targetStores:
          (data['targetStores'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const [],
      isFavorite: data['isFavorite'] as bool? ?? false,
      favoriteRank: _parseRank(data['favoriteRank']),
    );
  }

  int? _parseRank(dynamic raw) {
    final value = (raw as num?)?.toInt();
    if (value == null || value < 1) {
      return null;
    }
    return value;
  }
}
