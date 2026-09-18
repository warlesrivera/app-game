import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/models/chat_message.dart';

class AiChatRemoteDataSource {
  AiChatRemoteDataSource({
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

  DocumentReference<Map<String, dynamic>> _chatDoc(String gameId) {
    return _firestore.collection('users').doc(_uid).collection('ai_chats').doc(gameId);
  }

  CollectionReference<Map<String, dynamic>> _messages(String gameId) {
    return _chatDoc(gameId).collection('messages');
  }

  Stream<List<ChatMessage>> watchMessages(String gameId) {
    if ((Firebase.apps.isEmpty && _firestoreOverride == null) ||
        _auth.currentUser == null) {
      return Stream.value(const []);
    }

    return _messages(gameId)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return ChatMessage(
              id: doc.id,
              role: data['role'] == 'assistant'
                  ? ChatRole.assistant
                  : ChatRole.user,
              text: data['text'] as String? ?? '',
              createdAt: data['createdAt'] is Timestamp
                  ? (data['createdAt'] as Timestamp).toDate()
                  : null,
            );
          }).toList();
        });
  }

  Future<void> ensureChat({
    required String gameId,
    required String gameName,
  }) {
    return _chatDoc(gameId).set({
      'gameId': gameId,
      'gameName': gameName,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> addMessage({
    required String gameId,
    required ChatRole role,
    required String text,
  }) {
    return _messages(gameId).add({
      'role': role == ChatRole.assistant ? 'assistant' : 'user',
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
