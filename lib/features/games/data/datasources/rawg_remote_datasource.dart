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

  Future<Game> getGameById(String id) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/games/$id',
      );
      final data = response.data;
      if (data == null) {
        throw const NetworkFailure('empty', 'No se encontró el juego.');
      }
      return _mapRawgGame(data);
    } on DioException catch (error) {
      throw NetworkFailure(
        error.response?.statusCode?.toString() ?? 'network',
        'No se pudo cargar el juego.',
      );
    }
  }
}

Game _mapRawgGame(Map<String, dynamic> json) {
  return Game(
    id: '${json['id']}',
    name: json['name'] as String? ?? '',
    description: json['description_raw'] as String?,
    releaseDate: DateTime.tryParse(json['released'] as String? ?? ''),
    coverUrl: json['background_image'] as String?,
    rating: (json['rating'] as num?)?.toDouble(),
    platforms: _platformNames(json['platforms']),
    genres: _namedValues(json['genres']),
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
