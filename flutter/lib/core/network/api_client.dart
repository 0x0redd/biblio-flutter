import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import 'interceptors.dart';

class ApiClient {
  ApiClient._();

  static ApiClient? _instance;
  static Dio? _dio;

  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }

  Dio get dio {
    if (_dio != null) return _dio!;
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio!.interceptors.add(AuthInterceptor(_dio!));
    return _dio!;
  }

  static void reset() {
    _dio = null;
    _instance = null;
  }
}
