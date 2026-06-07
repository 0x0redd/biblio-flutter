import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({UserService? userService})
      : _userService = userService ?? UserService();

  final UserService _userService;

  ThemeMode themeMode = ThemeMode.system;
  String language = 'en';
  bool notificationsEnabled = true;

  Future<void> loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme') ?? 'system';
    themeMode = _themeFromString(theme);
    language = prefs.getString('language') ?? 'en';
    notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    notifyListeners();
  }

  Future<void> applyUserSettings(UserSettings settings) async {
    themeMode = _themeFromString(settings.theme);
    language = settings.language;
    notificationsEnabled = settings.notificationsEnabled;
    await _saveLocal(settings);
    notifyListeners();
  }

  Future<void> setTheme(String theme, {bool syncServer = true}) async {
    themeMode = _themeFromString(theme);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);
    notifyListeners();

    if (syncServer) {
      try {
        await _userService.updateSettings(
          UserSettings(
            theme: theme,
            language: language,
            notificationsEnabled: notificationsEnabled,
          ),
        );
      } catch (_) {}
    }
  }

  Future<void> setLanguage(String lang) async {
    language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    notifyListeners();
    try {
      await _userService.updateSettings(
        UserSettings(
          theme: _stringFromTheme(themeMode),
          language: lang,
          notificationsEnabled: notificationsEnabled,
        ),
      );
    } catch (_) {}
  }

  Future<void> setNotifications(bool enabled) async {
    notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    notifyListeners();
    try {
      await _userService.updateSettings(
        UserSettings(
          theme: _stringFromTheme(themeMode),
          language: language,
          notificationsEnabled: enabled,
        ),
      );
    } catch (_) {}
  }

  Future<void> _saveLocal(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', settings.theme);
    await prefs.setString('language', settings.language);
    await prefs.setBool('notifications_enabled', settings.notificationsEnabled);
  }

  ThemeMode _themeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _stringFromTheme(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
