import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../utils/token_storage.dart';

typedef OnUnauthorized = void Function();

OnUnauthorized? onUnauthorized;

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._dio);

  final Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains(ApiConstants.authLogin) &&
        !err.requestOptions.path.contains(ApiConstants.authRefresh)) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final token = await _tokenStorage.getAccessToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $token';
        try {
          final response = await _dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          // fall through
        }
      }
      await _tokenStorage.clearTokens();
      onUnauthorized?.call();
    }
    handler.next(err);
  }

  Future<bool> _tryRefresh() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await _dio.post(
        ApiConstants.authRefresh,
        data: {'refreshToken': refreshToken},
      );
      final data = response.data as Map<String, dynamic>;
      await _tokenStorage.saveTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
