import 'package:hive_flutter/hive_flutter.dart';

class AdvisorReplyCache {
  AdvisorReplyCache(this._box);

  static const boxName = 'advisor_reply_v1';
  static const ttl = Duration(days: 7);

  final Box<dynamic> _box;

  String? read(String key) {
    final raw = _box.get(key);
    if (raw is! Map) {
      return null;
    }
    final savedAt = raw['at'];
    final text = raw['text'];
    if (savedAt is! int || text is! String || text.isEmpty) {
      return null;
    }
    final age = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(savedAt),
    );
    if (age > ttl) {
      _box.delete(key);
      return null;
    }
    return text;
  }

  Future<void> write(String key, String text) {
    return _box.put(key, {
      'at': DateTime.now().millisecondsSinceEpoch,
      'text': text,
    });
  }

  static String keyFor({
    required String question,
    required String fingerprint,
  }) {
    return '${foldKey(question)}|$fingerprint';
  }

  static String foldKey(String question) {
    return question.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
