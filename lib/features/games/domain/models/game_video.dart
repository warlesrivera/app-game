import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_video.freezed.dart';
part 'game_video.g.dart';

Map<String, dynamic> _normalizeRawgVideo(Map<String, dynamic> json) {
  return {
    'id': '${json['id'] ?? ''}',
    'name': json['name'] as String? ?? '',
    'preview': _asHttpUrl(json['preview']),
    'url': _asHttpUrl(json['url']).isNotEmpty
        ? _asHttpUrl(json['url'])
        : _videoUrlFromData(json['data']),
  };
}

String _videoUrlFromData(dynamic data) {
  if (data is String) {
    return _asHttpUrl(data);
  }
  if (data is! Map) {
    return '';
  }

  final map = Map<dynamic, dynamic>.from(data);
  for (final key in const ['max', '720', '480', 'full', '320']) {
    final url = _asHttpUrl(map[key] ?? map[int.tryParse(key)]);
    if (url.isNotEmpty) {
      return url;
    }
  }

  for (final value in map.values) {
    final nested = _videoUrlFromData(value);
    if (nested.isNotEmpty) {
      return nested;
    }
  }
  return '';
}

String _asHttpUrl(dynamic value) {
  if (value is! String) {
    return '';
  }
  final url = value.trim();
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url;
  }
  return '';
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
