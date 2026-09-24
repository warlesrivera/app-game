import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/models/gaming_models.dart';

class GamingAdvisorRemoteDataSource {
  GamingAdvisorRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DocumentReference<Map<String, dynamic>>? get _profile {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return null;
    }
    return _firestore.collection('users').doc(uid).collection('gaming_profile').doc('main');
  }

  CollectionReference<Map<String, dynamic>>? get _memories {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return null;
    }
    return _firestore.collection('users').doc(uid).collection('gaming_memories');
  }

  CollectionReference<Map<String, dynamic>>? get _experiences {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return null;
    }
    return _firestore.collection('users').doc(uid).collection('game_experiences');
  }

  CollectionReference<Map<String, dynamic>>? get _messages {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return null;
    }
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('advisor_chat')
        .doc('main')
        .collection('messages');
  }

  Future<GamingProfile> getProfile() async {
    final ref = _profile;
    if (ref == null) {
      return const GamingProfile();
    }
    final snap = await ref.get();
    final data = snap.data();
    if (data == null) {
      return const GamingProfile();
    }
    return GamingProfile.fromJson(data);
  }

  Future<void> saveProfile(GamingProfile profile) async {
    await _profile?.set(profile.toJson());
  }

  Future<List<GamingMemory>> getMemories() async {
    final ref = _memories;
    if (ref == null) {
      return const [];
    }
    final snap = await ref.get();
    return [
      for (final doc in snap.docs) GamingMemory.fromJson(doc.id, doc.data()),
    ];
  }

  Future<void> saveMemory(GamingMemory memory) async {
    await _memories?.doc(memory.id).set(memory.toJson());
  }

  Future<void> deleteMemory(String id) async {
    await _memories?.doc(id).delete();
  }

  Future<void> saveExperience(GameExperience experience) async {
    await _experiences?.doc(experience.gameId).set(experience.toJson());
  }

  Future<List<GameExperience>> getExperiences() async {
    final ref = _experiences;
    if (ref == null) {
      return const [];
    }
    final snap = await ref.get();
    return [
      for (final doc in snap.docs) GameExperience.fromJson(doc.id, doc.data()),
    ];
  }

  Future<List<AdvisorMessage>> getMessages() async {
    final ref = _messages;
    if (ref == null) {
      return const [];
    }
    final snap = await ref.orderBy('createdAt').limit(40).get();
    return [
      for (final doc in snap.docs) AdvisorMessage.fromJson(doc.id, doc.data()),
    ];
  }

  Future<void> saveMessage(AdvisorMessage message) async {
    await _messages?.doc(message.id).set(message.toJson());
  }

  Future<void> clearMessages() async {
    final ref = _messages;
    if (ref == null) {
      return;
    }
    final snap = await ref.get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }
}
