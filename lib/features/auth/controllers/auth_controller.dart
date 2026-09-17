import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  bool get isAuthenticated => currentUser.value != null;

  static const String _tokenKey = 'circle_auth_token';
  static const String _userKey = 'circle_auth_user';

  Future<bool> tryAutoLogin() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      if (token == null || token.isEmpty) {
        isLoading.value = false;
        return false;
      }

      try {
        final response = await ApiService.get('/auth/me', token: token);
        if (response['success'] == true && response['user'] != null) {
          currentUser.value = UserModel.fromJson(response['user'], token: token);
          await _persistSession(token, currentUser.value!);
          isLoading.value = false;
          return true;
        }
      } catch (e) {
        final cachedUserStr = prefs.getString(_userKey);
        if (cachedUserStr != null) {
          final userData = jsonDecode(cachedUserStr) as Map<String, dynamic>;
          currentUser.value = UserModel.fromJson(userData, token: token);
          isLoading.value = false;
          return true;
        }
      }

      await logout(prompt: false);
      isLoading.value = false;
      return false;
    } catch (_) {
      isLoading.value = false;
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String studentNo,
    required String email,
    required bool isSocietyMember,
    required String password,
  }) async {
    errorMessage.value = '';
    isLoading.value = true;

    try {
      final response = await ApiService.post('/auth/register', {
        'name': name.trim(),
        'studentNo': studentNo.trim().toUpperCase(),
        'email': email.trim().toLowerCase(),
        'isSocietyMember': isSocietyMember,
        'password': password,
      });

      final token = response['token'] as String;
      final userMap = response['user'] as Map<String, dynamic>;
      currentUser.value = UserModel.fromJson(userMap, token: token);

      await _persistSession(token, currentUser.value!);
      isLoading.value = false;

      Get.offAllNamed(Routes.HOME);
      Get.snackbar(
        'Welcome to Circle!',
        'Account created successfully.',
        backgroundColor: Colors.indigo.shade50,
        colorText: Colors.indigo.shade900,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return true;
    } catch (e) {
      errorMessage.value = _cleanErrorMessage(e.toString());
      isLoading.value = false;
      Get.snackbar(
        'Registration Failed',
        errorMessage.value,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
  }

  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    errorMessage.value = '';
    isLoading.value = true;

    try {
      final response = await ApiService.post('/auth/login', {
        'identifier': identifier.trim(),
        'password': password,
      });

      final token = response['token'] as String;
      final userMap = response['user'] as Map<String, dynamic>;
      currentUser.value = UserModel.fromJson(userMap, token: token);

      await _persistSession(token, currentUser.value!);
      isLoading.value = false;

      Get.offAllNamed(Routes.HOME);
      Get.snackbar(
        'Welcome Back',
        'Signed in as ${currentUser.value?.name ?? "Student"}',
        backgroundColor: Colors.indigo.shade50,
        colorText: Colors.indigo.shade900,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return true;
    } catch (e) {
      errorMessage.value = _cleanErrorMessage(e.toString());
      isLoading.value = false;
      Get.snackbar(
        'Sign In Failed',
        errorMessage.value,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
  }

  Future<void> logout({bool prompt = true}) async {
    currentUser.value = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (_) {}

    Get.offAllNamed(Routes.LOGIN);
    if (prompt) {
      Get.snackbar(
        'Signed Out',
        'You have successfully signed out.',
        backgroundColor: Colors.grey.shade100,
        colorText: Colors.black87,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Future<void> _persistSession(String token, UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
    } catch (_) {}
  }

  String _cleanErrorMessage(String raw) {
    var msg = raw.replaceFirst('Exception: ', '');
    if (msg.contains('SocketException')) {
      return 'Unable to reach backend server. Please verify your connection.';
    }
    return msg;
  }
}
