import 'package:dio/dio.dart';

import '../../domain/models/game_guide.dart';

class WikipediaGuideRemoteDataSource {
  WikipediaGuideRemoteDataSource({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://es.wikipedia.org',
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
              headers: const {
                'User-Agent': 'GameVault/1.0 (https://gamevault.app)',
              },
            ),
          );

  final Dio _dio;

  Future<GameGuide?> search(String gameName) async {
    try {
      final searchResponse = await _dio.get<Map<String, dynamic>>(
        '/w/api.php',
        queryParameters: {
          'action': 'query',
          'list': 'search',
          'srsearch': '$gameName videojuego',
          'format': 'json',
          'origin': '*',
          'srlimit': 1,
        },
      );
      final query = searchResponse.data?['query'];
      if (query is! Map) {
        return null;
      }
      final results = query['search'] as List<dynamic>? ?? [];
      if (results.isEmpty || results.first is! Map) {
        return null;
      }
      final title = (results.first as Map)['title'] as String?;
      if (title == null || title.isEmpty) {
        return null;
      }

      final summaryResponse = await _dio.get<Map<String, dynamic>>(
        '/api/rest_v1/page/summary/${Uri.encodeComponent(title)}',
      );
      final data = summaryResponse.data;
      if (data == null) {
        return null;
      }
      final extract = (data['extract'] as String?)?.trim();
      if (extract == null || extract.isEmpty) {
        return null;
      }
      final wikiUrl =
          data['content_urls']?['desktop']?['page'] as String? ??
          'https://es.wikipedia.org/wiki/${Uri.encodeComponent(title)}';
      return GameGuide(
        summary: extract,
        sourceLabel: 'Wikipedia',
        wikiUrl: wikiUrl,
      );
    } on DioException {
      return null;
    }
  }
}
