import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../../../library/domain/models/library_game.dart';
import '../../../library/domain/models/library_status.dart';

class PlayerAnalysis extends Equatable {
  const PlayerAnalysis({
    required this.title,
    required this.summary,
    required this.details,
    required this.fingerprint,
  });

  final String title;
  final String summary;
  final String details;
  final String fingerprint;

  bool get hasContent => title.trim().isNotEmpty || summary.trim().isNotEmpty;

  factory PlayerAnalysis.fromJson(Map<String, dynamic> json) {
    return PlayerAnalysis(
      title: (json['title'] as String?)?.trim() ?? '',
      summary: (json['summary'] as String?)?.trim() ?? '',
      details: (json['details'] as String?)?.trim() ?? '',
      fingerprint: (json['fingerprint'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'summary': summary,
      'details': details,
      'fingerprint': fingerprint,
    };
  }

  PlayerAnalysis copyWith({String? fingerprint}) {
    return PlayerAnalysis(
      title: title,
      summary: summary,
      details: details,
      fingerprint: fingerprint ?? this.fingerprint,
    );
  }

  static PlayerAnalysis? tryParse(String? raw, {required String fingerprint}) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    final json = _extractJson(raw);
    if (json != null) {
      final parsed = PlayerAnalysis.fromJson(json);
      if (parsed.hasContent) {
        return parsed.copyWith(fingerprint: fingerprint);
      }
    }

    final lines = raw
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.isEmpty) {
      return null;
    }
    return PlayerAnalysis(
      title: lines.first,
      summary: lines.skip(1).join('\n'),
      details: lines.skip(1).join('\n'),
      fingerprint: fingerprint,
    );
  }

  static Map<String, dynamic>? _extractJson(String raw) {
    var text = raw.trim();
    if (text.startsWith('```')) {
      text = text
          .replaceFirst(RegExp(r'^```(?:json)?', caseSensitive: false), '')
          .replaceFirst(RegExp(r'```$'), '')
          .trim();
    }
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start < 0 || end <= start) {
      return null;
    }
    try {
      final decoded = jsonDecode(text.substring(start, end + 1));
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
    return null;
  }

  static String fingerprintFor(Iterable<LibraryGame> games) {
    final completed = <String>[];
    final incomplete = <String>[];
    final favorites = <LibraryGame>[];

    for (final item in games) {
      if (item.entry.status == LibraryStatus.completed) {
        completed.add(item.game.id);
      } else {
        incomplete.add(item.game.id);
      }
      if (item.entry.isFavorite && item.entry.canBeFavorite) {
        favorites.add(item);
      }
    }

    completed.sort();
    incomplete.sort();
    favorites.sort((a, b) {
      final rankA = a.entry.favoriteRank ?? 9999;
      final rankB = b.entry.favoriteRank ?? 9999;
      if (rankA != rankB) {
        return rankA.compareTo(rankB);
      }
      return a.game.id.compareTo(b.game.id);
    });

    return [
      'c:${completed.join(',')}',
      'i:${incomplete.join(',')}',
      'f:${favorites.map((item) => item.game.id).join(',')}',
    ].join('|');
  }

  @override
  List<Object?> get props => [title, summary, details, fingerprint];
}
