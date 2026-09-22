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

  Future<GameGuide?> search(String gameName, {int? releaseYear}) async {
    final clean = _cleanTitle(gameName);
    if (clean.isEmpty) {
      return null;
    }

    final titles = <String>[
      '$clean (videojuego)',
      if (releaseYear != null) '$clean (videojuego de $releaseYear)',
      clean,
    ];

    for (final title in titles) {
      final guide = await _extractByTitle(title);
      if (guide != null) {
        return guide;
      }
    }

    final found = await _searchTitle(clean);
    if (found == null) {
      return null;
    }
    return _extractByTitle(found);
  }

  Future<GameGuide?> _extractByTitle(String title) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/w/api.php',
        queryParameters: {
          'action': 'query',
          'prop': 'extracts',
          'titles': title,
          'format': 'json',
          'formatversion': 2,
          'redirects': 1,
          'origin': '*',
        },
      );
      final query = response.data?['query'];
      if (query is! Map) {
        return null;
      }
      final pages = query['pages'];
      if (pages is! List || pages.isEmpty || pages.first is! Map) {
        return null;
      }
      final page = Map<String, dynamic>.from(pages.first as Map);
      if (page['missing'] == true) {
        return null;
      }
      final extract = (page['extract'] as String?)?.trim();
      if (extract == null || extract.isEmpty) {
        return null;
      }
      final resolved = (page['title'] as String?)?.trim();
      final wikiTitle = (resolved == null || resolved.isEmpty) ? title : resolved;
      return GameGuide(
        html: extract,
        summary: _plainText(extract),
        sourceLabel: 'Wikipedia',
        wikiUrl:
            'https://es.wikipedia.org/wiki/${Uri.encodeComponent(wikiTitle.replaceAll(' ', '_'))}',
      );
    } on DioException {
      rethrow;
    }
  }

  Future<String?> _searchTitle(String gameName) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/w/api.php',
        queryParameters: {
          'action': 'query',
          'list': 'search',
          'srsearch': '$gameName videojuego',
          'format': 'json',
          'formatversion': 2,
          'origin': '*',
          'srlimit': 1,
        },
      );
      final query = response.data?['query'];
      if (query is! Map) {
        return null;
      }
      final results = query['search'] as List<dynamic>? ?? [];
      if (results.isEmpty || results.first is! Map) {
        return null;
      }
      final title = (results.first as Map)['title'] as String?;
      if (title == null || title.trim().isEmpty) {
        return null;
      }
      return title.trim();
    } on DioException {
      rethrow;
    }
  }

  String _cleanTitle(String gameName) {
    return gameName
        .replaceAll(RegExp(r'\s*\(videojuego( de \d{4})?\)\s*$', caseSensitive: false), '')
        .trim();
  }

  String _plainText(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
