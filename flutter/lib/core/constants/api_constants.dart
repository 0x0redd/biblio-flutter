import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class ApiConstants {
  ApiConstants._();

  /// Web, Windows, iOS simulator → 127.0.0.1
  /// Android emulator only → 10.0.2.2 (maps to host localhost)
  static String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://127.0.0.1:3000/api';
  }

  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authLogout = '/auth/logout';
  static const String authRefresh = '/auth/refresh';

  static const String books = '/books';
  static const String booksSearch = '/books/search';
  static const String booksCategories = '/books/categories';

  static const String usersMe = '/users/me';
  static const String usersSettings = '/users/me/settings';
  static const String usersFavorites = '/users/me/favorites';
  static const String usersReadingList = '/users/me/reading-list';

  static const String reviews = '/reviews';
}
