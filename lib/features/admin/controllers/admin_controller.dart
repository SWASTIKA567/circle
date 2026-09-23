import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../notes/controllers/notes_controller.dart';
import '../../notes/models/note_model.dart';
import '../../societies/controllers/societies_controller.dart';
import '../../societies/models/society_model.dart';

class AdminController extends GetxController {
  final RxList<NoteModel> pendingNotes = <NoteModel>[].obs;
  final RxList<SocietyModel> pendingSocieties = <SocietyModel>[].obs;
  final RxMap<String, dynamic> stats = <String, dynamic>{}.obs;

  final RxBool isLoading = false.obs;
  final RxBool isActionInProgress = false.obs;
  final RxString errorMessage = ''.obs;

  String? get _token {
    if (Get.isRegistered<AuthController>()) {
      return Get.find<AuthController>().currentUser.value?.token;
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    fetchAllPending();
  }

  Future<void> fetchAllPending() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = _token;
      if (token == null) {
        throw Exception('Admin authentication token required.');
      }

      await Future.wait([
        _fetchPendingNotes(token),
        _fetchPendingSocieties(token),
        _fetchStats(token),
      ]);
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchPendingNotes(String token) async {
    try {
      final response = await ApiService.get('/admin/pending-notes', token: token);
      if (response['success'] == true && response['notes'] is List) {
        final List list = response['notes'];
        pendingNotes.value =
            list.map((e) => NoteModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
  }

  Future<void> _fetchPendingSocieties(String token) async {
    try {
      final response = await ApiService.get('/admin/pending-societies', token: token);
      if (response['success'] == true && response['societies'] is List) {
        final List list = response['societies'];
        pendingSocieties.value =
            list.map((e) => SocietyModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
  }

  Future<void> _fetchStats(String token) async {
    try {
      final response = await ApiService.get('/admin/stats', token: token);
      if (response['success'] == true && response['stats'] != null) {
        stats.value = response['stats'];
      }
    } catch (_) {}
  }

  Future<void> approveNote(String noteId) async {
    try {
      isActionInProgress.value = true;
      final token = _token;
      if (token == null) return;

      final response = await ApiService.put('/admin/notes/$noteId/approve', {}, token: token);

      if (response['success'] == true) {
        pendingNotes.removeWhere((n) => n.id == noteId);
        if (Get.isRegistered<NotesController>()) {
          Get.find<NotesController>().fetchNotes();
        }
        _fetchStats(token);

        Get.snackbar(
          'Note Approved ✅',
          response['message'] ?? 'Note is now publicly visible to all students.',
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade900,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Approval Failed',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isActionInProgress.value = false;
    }
  }

  Future<void> rejectNote(String noteId) async {
    try {
      isActionInProgress.value = true;
      final token = _token;
      if (token == null) return;

      final response = await ApiService.delete('/admin/notes/$noteId/reject', token: token);

      if (response['success'] == true) {
        pendingNotes.removeWhere((n) => n.id == noteId);
        _fetchStats(token);

        Get.snackbar(
          'Note Rejected 🗑️',
          response['message'] ?? 'Note was removed from approval queue.',
          backgroundColor: Colors.orange.shade50,
          colorText: Colors.orange.shade900,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Rejection Failed',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isActionInProgress.value = false;
    }
  }

  Future<void> approveSociety(String societyId) async {
    try {
      isActionInProgress.value = true;
      final token = _token;
      if (token == null) return;

      final response =
          await ApiService.put('/admin/societies/$societyId/approve', {}, token: token);

      if (response['success'] == true) {
        pendingSocieties.removeWhere((s) => s.id == societyId);
        if (Get.isRegistered<SocietiesController>()) {
          Get.find<SocietiesController>().fetchSocieties();
        }
        _fetchStats(token);

        Get.snackbar(
          'Society Approved ✅',
          response['message'] ?? 'Society is now visible in campus clubs.',
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade900,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Approval Failed',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isActionInProgress.value = false;
    }
  }

  Future<void> rejectSociety(String societyId) async {
    try {
      isActionInProgress.value = true;
      final token = _token;
      if (token == null) return;

      final response =
          await ApiService.delete('/admin/societies/$societyId/reject', token: token);

      if (response['success'] == true) {
        pendingSocieties.removeWhere((s) => s.id == societyId);
        _fetchStats(token);

        Get.snackbar(
          'Society Rejected 🗑️',
          response['message'] ?? 'Society request was removed.',
          backgroundColor: Colors.orange.shade50,
          colorText: Colors.orange.shade900,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Rejection Failed',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isActionInProgress.value = false;
    }
  }
}
