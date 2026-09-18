import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  ApiClient({
    required String baseUrl,
    required String apiKey,
    Dio? dio,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl,
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 10),
               sendTimeout: const Duration(seconds: 10),
             ),
           ) {
    _dio.interceptors.add(_RawgKeyInterceptor(apiKey));
    if (kDebugMode) {
      _dio.interceptors.add(_DebugLogInterceptor());
    }
  }

  final Dio _dio;

  Dio get dio => _dio;
}

class _RawgKeyInterceptor extends Interceptor {
  _RawgKeyInterceptor(this._apiKey);

  final String _apiKey;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.queryParameters['key'] = _apiKey;
    handler.next(options);
  }
}

class _DebugLogInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    debugPrint('→ ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    debugPrint(
      '← ${response.statusCode} ${response.requestOptions.path}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '✖ ${err.response?.statusCode} ${err.requestOptions.path}: ${err.message}',
    );
    handler.next(err);
  }
}
