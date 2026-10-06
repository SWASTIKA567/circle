import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_theme.dart';
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
        final response = await ApiService.get('/auth/me', token: token)
            .timeout(const Duration(seconds: 3));
        if (response['success'] == true && response['user'] != null) {
          currentUser.value = UserModel.fromJson(response['user'], token: token);
          await _persistSession(token, currentUser.value!);
          isLoading.value = false;
          return true;
        }
      } catch (e) {
        final cachedUserStr = prefs.getString(_userKey);
        if (cachedUserStr != null) {
          try {
            final userData = jsonDecode(cachedUserStr) as Map<String, dynamic>;
            currentUser.value = UserModel.fromJson(userData, token: token);
            isLoading.value = false;
            return true;
          } catch (_) {}
        }
      }

      // If token is invalid or server failed, clean up cached session silently
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      currentUser.value = null;
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
        backgroundColor: AppColors.card,
        colorText: AppColors.white,
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
        backgroundColor: AppColors.pinkLight,
        colorText: AppColors.magenta,
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

      // Prompt "Are you a Society Member?" right after login
      showSocietyMemberPrompt(
        onDone: () {
          Get.offAllNamed(Routes.HOME);
        },
      );
      return true;
    } catch (e) {
      errorMessage.value = _cleanErrorMessage(e.toString());
      isLoading.value = false;
      Get.snackbar(
        'Sign In Failed',
        errorMessage.value,
        backgroundColor: AppColors.pinkLight,
        colorText: AppColors.magenta,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
  }

  Future<bool> updateSocietyStatus(bool isMember) async {
    try {
      final token = currentUser.value?.token;
      if (token != null && token.isNotEmpty) {
        final response = await ApiService.put(
          '/auth/society-status',
          {'isSocietyMember': isMember},
          token: token,
        );

        if (response['user'] != null && currentUser.value != null) {
          final updatedUser = UserModel.fromJson(
            response['user'] as Map<String, dynamic>,
            token: token,
          );
          currentUser.value = updatedUser;
          await _persistSession(token, updatedUser);
          return true;
        }
      }

      if (currentUser.value != null) {
        final updated = currentUser.value!.copyWith(isSocietyMember: isMember);
        currentUser.value = updated;
        if (updated.token != null) {
          await _persistSession(updated.token!, updated);
        }
      }
      return true;
    } catch (e) {
      // Local fallback
      if (currentUser.value != null) {
        final updated = currentUser.value!.copyWith(isSocietyMember: isMember);
        currentUser.value = updated;
        if (updated.token != null) {
          await _persistSession(updated.token!, updated);
        }
      }
      return false;
    }
  }

  void showSocietyMemberPrompt({VoidCallback? onDone}) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    color: AppColors.purpleLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.groups_rounded,
                    color: AppColors.card,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Are you a Society Member?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Are you an active coordinator, core team member, or lead of any college society/club in AKGEC?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.gray,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                // Option 1: Yes, I am a Society Member
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.card,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.verified_rounded, size: 20, color: AppColors.purple),
                    label: const Text(
                      "Yes, I'm a Society Member",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    onPressed: () async {
                      Get.back();
                      await updateSocietyStatus(true);
                      if (onDone != null) {
                        onDone();
                      }
                      Get.snackbar(
                        'Member Access Enabled ★',
                        'You can now create and manage societies with full member privileges.',
                        backgroundColor: AppColors.card,
                        colorText: AppColors.white,
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(16),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // Option 2: No, Regular Student
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.text,
                      side: BorderSide(color: AppColors.grayFade(0.2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      Get.back();
                      await updateSocietyStatus(false);
                      if (onDone != null) {
                        onDone();
                      }
                      Get.snackbar(
                        'Welcome to Circle',
                        'Signed in as ${currentUser.value?.name ?? "Student"}',
                        backgroundColor: AppColors.card,
                        colorText: AppColors.white,
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(16),
                      );
                    },
                    child: const Text(
                      'No, Regular Student',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.gray,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
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
    if (msg.contains('TimeoutException') || msg.contains('Future not completed')) {
      return 'Server is waking up. Please wait a few seconds and try again or sign in directly.';
    }
    if (msg.contains('SocketException')) {
      return 'Unable to reach backend server. Please verify your connection.';
    }
    return msg;
  }
}
