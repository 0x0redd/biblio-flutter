import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/utils/token_storage.dart';
import '../models/user_model.dart';

class AuthService {
  AuthService({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _dio = (apiClient ?? ApiClient.instance).dio,
        _tokenStorage = tokenStorage ?? TokenStorage();

  final Dio _dio;
  final TokenStorage _tokenStorage;

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.authRegister,
      data: {'name': name, 'email': email, 'password': password},
    );
    return _handleAuthResponse(response.data as Map<String, dynamic>);
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.authLogin,
      data: {'email': email, 'password': password},
    );
    return _handleAuthResponse(response.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    try {
      await _dio.post(
        ApiConstants.authLogout,
        data: {'refreshToken': refreshToken},
      );
    } catch (_) {
      // ignore
    }
    await _tokenStorage.clearTokens();
  }

  Future<UserModel?> validateSession() async {
    final token = await _tokenStorage.getAccessToken();
    if (token == null) return null;

    try {
      final response = await _dio.get(ApiConstants.usersMe);
      final data = response.data as Map<String, dynamic>;
      return UserModel.fromJson(data['data'] as Map<String, dynamic>);
    } catch (_) {
      await _tokenStorage.clearTokens();
      return null;
    }
  }

  Future<UserModel> _handleAuthResponse(Map<String, dynamic> data) async {
    await _tokenStorage.saveTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }
}
