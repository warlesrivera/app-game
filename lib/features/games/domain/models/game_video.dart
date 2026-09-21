import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_video.freezed.dart';
part 'game_video.g.dart';

Map<String, dynamic> _normalizeRawgVideo(Map<String, dynamic> json) {
  final data = json['data'];
  String url = json['url'] as String? ?? '';
  if (url.isEmpty && data is Map) {
    url = (data['max'] ?? data['480'] ?? data['720'] ?? '') as String? ?? '';
  }
  return {
    'id': '${json['id'] ?? ''}',
    'name': json['name'] as String? ?? '',
    'preview': json['preview'] as String? ?? '',
    'url': url,
  };
}

@freezed
abstract class GameVideo with _$GameVideo {
  const factory GameVideo({
    required String id,
    required String name,
    required String preview,
    required String url,
  }) = _GameVideo;

  factory GameVideo.fromJson(Map<String, dynamic> json) =>
      _$GameVideoFromJson(_normalizeRawgVideo(json));
}
