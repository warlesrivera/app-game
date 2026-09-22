import 'package:dio/dio.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/game.dart';

class RawgRemoteDataSource {
  RawgRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  static const int _pageSize = 20;

  Future<List<Game>> getDiscoverGames({int page = 1}) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/games',
        queryParameters: {
          'page': page,
          'page_size': _pageSize,
          'ordering': '-added',
        },
      );

      final results = response.data?['results'] as List<dynamic>? ?? [];
      return results
          .whereType<Map<dynamic, dynamic>>()
          .map((item) => _mapRawgGame(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (error) {
      throw NetworkFailure(
        error.response?.statusCode?.toString() ?? 'network',
        'No se pudo cargar el catálogo de juegos.',
      );
    }
  }

  Future<List<Game>> searchGames(String query) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/games',
        queryParameters: {
          'search': query,
          'page_size': _pageSize,
        },
      );

      final results = response.data?['results'] as List<dynamic>? ?? [];
      return results
          .whereType<Map<dynamic, dynamic>>()
          .map((item) => _mapRawgGame(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (error) {
      throw NetworkFailure(
        error.response?.statusCode?.toString() ?? 'network',
        'No se pudieron buscar juegos.',
      );
    }
  }

  Future<Game> getGameById(String id) {
    final parsed = int.tryParse(id);
    if (parsed == null) {
      throw const NetworkFailure('invalid-id', 'No se encontró el juego.');
    }
    return getGameDetails(parsed);
  }

  Future<Game> getGameDetails(int id) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/games/$id',
        queryParameters: {
          'key': _apiClient.apiKey,
        },
      );
      final data = response.data;
      if (data == null) {
        throw const NetworkFailure('empty', 'No se encontró el juego.');
      }
      final game = _mapRawgGame(data, isDetailed: true);
      final shots = await _getScreenshotUrls(id);
      return game.copyWith(
        screenshotUrls: _uniqueUrls([
          ...shots,
          ...game.screenshotUrls,
        ]),
      );
    } on DioException catch (error) {
      throw NetworkFailure(
        error.response?.statusCode?.toString() ?? 'network',
        'No se pudo cargar el juego.',
      );
    }
  }

  Future<List<String>> _getScreenshotUrls(int id) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/games/$id/screenshots',
        queryParameters: {
          'key': _apiClient.apiKey,
          'page_size': 40,
        },
      );
      final results = response.data?['results'] as List<dynamic>? ?? [];
      return _shortScreenshotUrls(results);
    } on DioException {
      return const [];
    }
  }

  Future<List<Game>> getCatalog({
    required String catalogId,
    int? parentPlatforms,
    String? platforms,
    String ordering = '-added',
    String? dates,
    int page = 1,
    int pageSize = 40,
  }) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/games',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          'ordering': ordering,
          'exclude_additions': true,
          if (parentPlatforms != null) 'parent_platforms': parentPlatforms,
          if (platforms != null) 'platforms': platforms,
          if (dates != null) 'dates': dates,
        },
      );

      final results = response.data?['results'] as List<dynamic>? ?? [];
      return results
          .whereType<Map<dynamic, dynamic>>()
          .map((item) => _mapRawgGame(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (error) {
      throw NetworkFailure(
        error.response?.statusCode?.toString() ?? 'network',
        'No se pudo cargar el catálogo $catalogId.',
      );
    }
  }
}

Game _mapRawgGame(Map<String, dynamic> json, {bool isDetailed = false}) {
  final coverUrl = json['background_image'] as String?;
  return Game(
    id: '${json['id']}',
    name: json['name'] as String? ?? '',
    description: _nonEmpty(json['description_raw'] as String?),
    releaseDate: DateTime.tryParse(json['released'] as String? ?? ''),
    coverUrl: coverUrl,
    rating: (json['rating'] as num?)?.toDouble(),
    platforms: _platformNames(json['platforms']),
    platformSlugs: _platformSlugs(json['platforms']),
    genres: _namedValues(json['genres']),
    screenshotUrls: _uniqueUrls([
      ..._shortScreenshotUrls(json['short_screenshots']),
      if (json['background_image_additional'] is String)
        json['background_image_additional'] as String,
    ]),
    developers: _namedValues(json['developers']),
    publishers: _namedValues(json['publishers']),
    tags: _namedValues(json['tags']).take(16).toList(),
    stores: _storeNames(json['stores']),
    isDetailed: isDetailed,
    website: _nonEmpty(json['website'] as String?),
    metacritic: (json['metacritic'] as num?)?.toInt(),
    playtime: (json['playtime'] as num?)?.toInt(),
    ratingsCount: (json['ratings_count'] as num?)?.toInt(),
    esrbRating: _esrbName(json['esrb_rating']),
    redditUrl: _nonEmpty(json['reddit_url'] as String?),
  );
}

List<String> _platformNames(dynamic raw) {
  if (raw is! List) {
    return const [];
  }

  return raw
      .map((item) {
        if (item is! Map) {
          return null;
        }
        final platform = item['platform'];
        if (platform is Map && platform['name'] is String) {
          return platform['name'] as String;
        }
        return item['name'] as String?;
      })
      .whereType<String>()
      .toList();
}

List<String> _platformSlugs(dynamic raw) {
  if (raw is! List) {
    return const [];
  }

  return raw
      .map((item) {
        if (item is! Map) {
          return null;
        }
        final platform = item['platform'];
        if (platform is Map && platform['slug'] is String) {
          return platform['slug'] as String;
        }
        return item['slug'] as String?;
      })
      .whereType<String>()
      .toList();
}

List<String> _namedValues(dynamic raw) {
  if (raw is! List) {
    return const [];
  }

  return raw
      .map((item) {
        if (item is Map && item['name'] is String) {
          return item['name'] as String;
        }
        return null;
      })
      .whereType<String>()
      .toList();
}

List<String> _storeNames(dynamic raw) {
  if (raw is! List) {
    return const [];
  }

  return raw
      .map((item) {
        if (item is! Map) {
          return null;
        }
        final store = item['store'];
        if (store is Map && store['name'] is String) {
          return store['name'] as String;
        }
        return item['name'] as String?;
      })
      .whereType<String>()
      .toList();
}

List<String> _shortScreenshotUrls(dynamic raw) {
  if (raw is! List) {
    return const [];
  }

  return raw
      .map((item) {
        if (item is Map && item['image'] is String) {
          return item['image'] as String;
        }
        return null;
      })
      .whereType<String>()
      .toList();
}

String? _esrbName(dynamic raw) {
  if (raw is Map && raw['name'] is String) {
    return raw['name'] as String;
  }
  return null;
}

String? _nonEmpty(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

List<String> _uniqueUrls(Iterable<String> urls, {String? skip}) {
  final seen = <String>{if (skip != null && skip.isNotEmpty) skip};
  final unique = <String>[];
  for (final url in urls) {
    if (url.isEmpty || !seen.add(url)) {
      continue;
    }
    unique.add(url);
  }
  return unique;
}
