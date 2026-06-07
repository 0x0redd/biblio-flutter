import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/book_model.dart';
import '../models/user_model.dart';

class UserService {
  UserService({ApiClient? apiClient})
      : _dio = (apiClient ?? ApiClient.instance).dio;

  final Dio _dio;

  Future<UserModel> getProfile() async {
    final response = await _dio.get(ApiConstants.usersMe);
    final body = response.data as Map<String, dynamic>;
    return UserModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<UserModel> updateProfile({String? name, String? avatarUrl}) async {
    final response = await _dio.put(
      ApiConstants.usersMe,
      data: {
        if (name != null) 'name': name,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      },
    );
    final body = response.data as Map<String, dynamic>;
    return UserModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<UserModel> updateSettings(UserSettings settings) async {
    final response = await _dio.put(
      ApiConstants.usersSettings,
      data: settings.toJson(),
    );
    final body = response.data as Map<String, dynamic>;
    return UserModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<UserModel> toggleFavorite(String bookId, {required bool add}) async {
    if (add) {
      final response =
          await _dio.post('${ApiConstants.usersFavorites}/$bookId');
      final body = response.data as Map<String, dynamic>;
      return UserModel.fromJson(body['data'] as Map<String, dynamic>);
    }
    final response =
        await _dio.delete('${ApiConstants.usersFavorites}/$bookId');
    final body = response.data as Map<String, dynamic>;
    return UserModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<UserModel> toggleReadingList(String bookId, {required bool add}) async {
    if (add) {
      final response =
          await _dio.post('${ApiConstants.usersReadingList}/$bookId');
      final body = response.data as Map<String, dynamic>;
      return UserModel.fromJson(body['data'] as Map<String, dynamic>);
    }
    final response =
        await _dio.delete('${ApiConstants.usersReadingList}/$bookId');
    final body = response.data as Map<String, dynamic>;
    return UserModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<BookModel>> getFavoriteBooks() async {
    final response = await _dio.get(ApiConstants.usersFavorites);
    final body = response.data as Map<String, dynamic>;
    return (body['data'] as List<dynamic>)
        .map((e) => BookModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<BookModel>> getReadingListBooks() async {
    final response = await _dio.get(ApiConstants.usersReadingList);
    final body = response.data as Map<String, dynamic>;
    return (body['data'] as List<dynamic>)
        .map((e) => BookModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteAccount() async {
    await _dio.delete(ApiConstants.usersMe);
  }
}
