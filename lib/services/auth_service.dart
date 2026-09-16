import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  static const String _tokenKey = 'circle_auth_token';
  static const String _userKey = 'circle_auth_user';

  // Check persisted auth session on app startup
  Future<bool> tryAutoLogin() async {
    try {
      _setLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      if (token == null || token.isEmpty) {
        _setLoading(false);
        return false;
      }

      // Verify token with backend /api/auth/me
      try {
        final response = await ApiService.get('/auth/me', token: token);
        if (response['success'] == true && response['user'] != null) {
          _currentUser = UserModel.fromJson(response['user'], token: token);
          await _persistSession(token, _currentUser!);
          _setLoading(false);
          notifyListeners();
          return true;
        }
      } catch (e) {
        // If server is unreachable but we have cached user, load cached user
        final cachedUserStr = prefs.getString(_userKey);
        if (cachedUserStr != null) {
          final userData = jsonDecode(cachedUserStr) as Map<String, dynamic>;
          _currentUser = UserModel.fromJson(userData, token: token);
          _setLoading(false);
          notifyListeners();
          return true;
        }
      }

      await logout();
      _setLoading(false);
      return false;
    } catch (_) {
      _setLoading(false);
      return false;
    }
  }

  // Register new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _clearError();
    _setLoading(true);

    try {
      final response = await ApiService.post('/auth/register', {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
      });

      final token = response['token'] as String;
      final userMap = response['user'] as Map<String, dynamic>;
      _currentUser = UserModel.fromJson(userMap, token: token);

      await _persistSession(token, _currentUser!);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _clearError();
    _setLoading(true);

    try {
      final response = await ApiService.post('/auth/login', {
        'email': email.trim().toLowerCase(),
        'password': password,
      });

      final token = response['token'] as String;
      final userMap = response['user'] as Map<String, dynamic>;
      _currentUser = UserModel.fromJson(userMap, token: token);

      await _persistSession(token, _currentUser!);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _persistSession(String token, UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  String _cleanErrorMessage(String raw) {
    return raw.replaceFirst('Exception: ', '').trim();
  }
}
