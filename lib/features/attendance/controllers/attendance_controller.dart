import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/services/api_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../models/attendance_model.dart';

class AttendanceController extends GetxController {
  static const String _cacheKey = 'cached_student_attendance';

  final Rx<AttendanceDataModel?> attendance = Rx<AttendanceDataModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  String? get _token {
    if (Get.isRegistered<AuthController>()) {
      return Get.find<AuthController>().currentUser.value?.token;
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    _loadCachedAttendance();
    fetchAttendance();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void updateSearch(String query) {
    searchQuery.value = query.trim().toLowerCase();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  List<AttendanceSubjectModel> get filteredSubjects {
    final data = attendance.value;
    if (data == null) return [];
    final q = searchQuery.value;
    if (q.isEmpty) return data.subjects;

    return data.subjects.where((s) {
      return s.subjectName.toLowerCase().contains(q) ||
          s.subjectCode.toLowerCase().contains(q) ||
          s.facultyName.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _loadCachedAttendance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString(_cacheKey);
      if (cachedStr != null && cachedStr.isNotEmpty) {
        final decoded = jsonDecode(cachedStr) as Map<String, dynamic>;
        attendance.value = AttendanceDataModel.fromJson(decoded, isFromCache: true);
      }
    } catch (_) {}
  }

  Future<void> _saveCachedAttendance(AttendanceDataModel data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(data.toJson()));
    } catch (_) {}
  }

  Future<void> fetchAttendance({bool refresh = false}) async {
    final token = _token;
    if (token == null || token.isEmpty) {
      errorMessage.value = 'Please sign in to view your attendance.';
      return;
    }

    try {
      if (refresh) {
        isRefreshing.value = true;
      } else if (attendance.value == null) {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final response = await ApiService.get('/attendance', token: token);

      if (response['success'] == true && response['attendance'] != null) {
        final isCache = response['isFromCache'] == true;
        final data = AttendanceDataModel.fromJson(
          response['attendance'] as Map<String, dynamic>,
          isFromCache: isCache,
        );
        attendance.value = data;
        await _saveCachedAttendance(data);
      } else {
        throw Exception(response['message'] ?? 'Failed to retrieve attendance data.');
      }
    } catch (e) {
      final cleanMsg = e.toString().replaceAll('Exception: ', '');
      // If we already have cached data, don't block the screen with full error
      if (attendance.value == null) {
        errorMessage.value = cleanMsg;
      } else {
        Get.snackbar(
          'Sync Notice',
          'Showing last synced attendance records. ($cleanMsg)',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<bool> linkCredentials(String password) async {
    final token = _token;
    if (token == null || token.isEmpty) return false;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await ApiService.post('/attendance/link', {
        'password': password,
      }, token: token);

      if (response['success'] == true && response['attendance'] != null) {
        final data = AttendanceDataModel.fromJson(
          response['attendance'] as Map<String, dynamic>,
          isFromCache: false,
        );
        attendance.value = data;
        await _saveCachedAttendance(data);
        isLoading.value = false;
        Get.snackbar(
          'ERP Synced',
          'Attendance loaded successfully!',
          backgroundColor: AppColors.greenLight,
          colorText: AppColors.green,
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to sync with ERP.');
      }
    } catch (e) {
      isLoading.value = false;
      final cleanMsg = e.toString().replaceAll('Exception: ', '');
      errorMessage.value = cleanMsg;
      Get.snackbar(
        'ERP Sync Failed',
        cleanMsg,
        backgroundColor: AppColors.pinkLight,
        colorText: AppColors.magenta,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }
}
