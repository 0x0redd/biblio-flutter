import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    AuthService? authService,
    UserService? userService,
  })  : _authService = authService ?? AuthService(),
        _userService = userService ?? UserService();

  final AuthService _authService;
  final UserService _userService;

  AuthStatus status = AuthStatus.unknown;
  UserModel? user;
  bool isLoading = false;
  String? error;

  Future<void> bootstrap() async {
    isLoading = true;
    notifyListeners();
    try {
      user = await _authService.validateSession();
      status =
          user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    } catch (_) {
      status = AuthStatus.unauthenticated;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      user = await _authService.login(email: email, password: password);
      status = AuthStatus.authenticated;
      return true;
    } catch (e) {
      error = _messageFromError(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      user = await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      status = AuthStatus.authenticated;
      return true;
    } catch (e) {
      error = _messageFromError(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    try {
      user = await _userService.getProfile();
      notifyListeners();
    } catch (_) {}
  }

  void updateUser(UserModel updated) {
    user = updated;
    notifyListeners();
  }

  String _messageFromError(Object e) {
    if (e.toString().contains('409')) return 'Email already registered';
    if (e.toString().contains('401')) return 'Invalid email or password';
    return 'Something went wrong. Please try again.';
  }
}
