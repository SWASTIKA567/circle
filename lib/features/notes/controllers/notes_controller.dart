import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/services/api_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../models/note_model.dart';

class NotesController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxString selectedCategory = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final RxList<NoteModel> notes = <NoteModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;
  final RxString errorMessage = ''.obs;

  final List<String> categories = [
    'All',
    'Semester 1',
    'Semester 2',
    'Semester 3',
    'Semester 4',
    'Semester 5',
    'Semester 6',
    'Semester 7',
    'Semester 8',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchNotes();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  List<NoteModel> get filteredNotes {
    return notes.where((note) {
      final matchesCategory = selectedCategory.value == 'All' ||
          note.semester.toLowerCase().trim() == selectedCategory.value.toLowerCase().trim() ||
          note.semester.toLowerCase().replaceAll(' ', '') == selectedCategory.value.toLowerCase().replaceAll(' ', '');

      final query = searchQuery.value.trim().toLowerCase();
      final matchesQuery = query.isEmpty ||
          note.title.toLowerCase().contains(query) ||
          note.subject.toLowerCase().contains(query) ||
          note.unit.toLowerCase().contains(query) ||
          note.branch.toLowerCase().contains(query) ||
          note.semester.toLowerCase().contains(query) ||
          note.fileName.toLowerCase().contains(query) ||
          note.author.toLowerCase().contains(query);

      return matchesCategory && matchesQuery;
    }).toList();
  }

  /// List of 8 semester boxes
  final List<Map<String, String>> semesterBoxes = const [
    {'key': 'Semester 1', 'title': '1st Semester', 'code': 'SEM 01'},
    {'key': 'Semester 2', 'title': '2nd Semester', 'code': 'SEM 02'},
    {'key': 'Semester 3', 'title': '3rd Semester', 'code': 'SEM 03'},
    {'key': 'Semester 4', 'title': '4th Semester', 'code': 'SEM 04'},
    {'key': 'Semester 5', 'title': '5th Semester', 'code': 'SEM 05'},
    {'key': 'Semester 6', 'title': '6th Semester', 'code': 'SEM 06'},
    {'key': 'Semester 7', 'title': '7th Semester', 'code': 'SEM 07'},
    {'key': 'Semester 8', 'title': '8th Semester', 'code': 'SEM 08'},
  ];

  /// Active semester entered by user. If null, shows the 8 semester boxes.
  final Rx<String?> currentSemester = Rx<String?>(null);

  void enterSemester(String semesterKey) {
    currentSemester.value = semesterKey;
    selectedCategory.value = semesterKey;
    clearSearch();
  }

  void exitSemester() {
    currentSemester.value = null;
    selectedCategory.value = 'All';
    clearSearch();
  }

  int countForSemester(String key) {
    final norm = key.toLowerCase().replaceAll(' ', '');
    return notes.where((n) => n.semester.toLowerCase().replaceAll(' ', '') == norm).length;
  }

  int countForCategory(String category) {
    if (category == 'All') return notes.length;
    final catNorm = category.toLowerCase().replaceAll(' ', '');
    return notes.where((n) => n.semester.toLowerCase().replaceAll(' ', '') == catNorm).length;
  }

  void selectCategory(String category) => selectedCategory.value = category;

  void updateSearch(String query) => searchQuery.value = query;

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  Future<void> fetchNotes() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      String? token;
      if (Get.isRegistered<AuthController>()) {
        token = Get.find<AuthController>().currentUser.value?.token;
      }

      final response = await ApiService.get('/notes', token: token);

      if (response['success'] == true && response['notes'] is List) {
        final List noteList = response['notes'];
        notes.value = noteList.map((e) => NoteModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> uploadNote({
    required File file,
    required String title,
    required String subject,
    required String semester,
    required String unit,
    String branch = 'All Branches',
  }) async {
    try {
      isUploading.value = true;

      String? token;
      String authorName = 'Student';

      if (Get.isRegistered<AuthController>()) {
        final auth = Get.find<AuthController>();
        token = auth.currentUser.value?.token;
        if (auth.currentUser.value?.name != null && auth.currentUser.value!.name.isNotEmpty) {
          authorName = auth.currentUser.value!.name;
        }
      }

      final fields = {
        'title': title.trim(),
        'subject': subject.trim(),
        'semester': semester.trim(),
        'unit': unit.trim(),
        'branch': branch.trim(),
        'author': authorName,
      };

      final response = await ApiService.uploadFile(
        '/notes/upload',
        file: file,
        fields: fields,
        fileField: 'pdf',
        token: token,
      );

      if (response['success'] == true && response['note'] != null) {
        final newNote = NoteModel.fromJson(response['note']);
        notes.removeWhere((n) => n.id == newNote.id);
        notes.insert(0, newNote);

        Get.snackbar(
          'Submitted for Approval ⏳',
          'Note "${newNote.title}" uploaded! It is waiting for admin approval (usually within a few minutes).',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.card,
          colorText: AppColors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        );
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to upload note');
      }
    } catch (e) {
      Get.snackbar(
        'Upload Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.pinkLight,
        colorText: AppColors.magenta,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
      return false;
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> openNotePdf(NoteModel note) async {
    String? token;
    if (Get.isRegistered<AuthController>()) {
      token = Get.find<AuthController>().currentUser.value?.token;
    }

    String pathUrl = note.fileUrl.isNotEmpty
        ? note.fileUrl
        : '/api/notes/file/${note.id}';

    String fullUrl = ApiService.resolveFileUrl(pathUrl);

    if (token != null && token.isNotEmpty && (fullUrl.contains('/api/notes/') || fullUrl.contains('/notes/'))) {
      final separator = fullUrl.contains('?') ? '&' : '?';
      fullUrl = '$fullUrl${separator}token=$token';
    }

    final uri = Uri.parse(fullUrl);

    try {
      final canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      Get.snackbar(
        'Could Not Open PDF',
        'Unable to open preview: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.pinkLight,
        colorText: AppColors.magenta,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Future<void> downloadNotePdf(NoteModel note) async {
    String? token;
    if (Get.isRegistered<AuthController>()) {
      token = Get.find<AuthController>().currentUser.value?.token;
    }

    String downloadUrl = ApiService.resolveFileUrl('/api/notes/download/${note.id}');
    if (token != null && token.isNotEmpty) {
      final separator = downloadUrl.contains('?') ? '&' : '?';
      downloadUrl = '$downloadUrl${separator}token=$token';
    }

    final uri = Uri.parse(downloadUrl);

    try {
      Get.snackbar(
        'Downloading Note',
        'Starting download for "${note.title}"...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.card,
        colorText: AppColors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );

      final canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      Get.snackbar(
        'Download Error',
        'Could not initiate download: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.pinkLight,
        colorText: AppColors.magenta,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Future<bool> approveNote(String noteId) async {
    try {
      String? token;
      if (Get.isRegistered<AuthController>()) {
        token = Get.find<AuthController>().currentUser.value?.token;
      }

      final response = await ApiService.put('/admin/notes/$noteId/approve', {}, token: token);

      if (response['success'] == true) {
        final idx = notes.indexWhere((n) => n.id == noteId);
        if (idx != -1) {
          final old = notes[idx];
          notes[idx] = NoteModel(
            id: old.id,
            title: old.title,
            subject: old.subject,
            semester: old.semester,
            unit: old.unit,
            branch: old.branch,
            author: old.author,
            fileName: old.fileName,
            fileUrl: old.fileUrl,
            fileSize: old.fileSize,
            pages: old.pages,
            status: 'approved',
            isApproved: true,
            createdAt: old.createdAt,
          );
        }

        Get.snackbar(
          'Note Approved ✅',
          response['message'] ?? 'Note approved and published for all students!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.card,
          colorText: AppColors.white,
          margin: const EdgeInsets.all(16),
        );
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Approval Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.pinkLight,
        colorText: AppColors.magenta,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
  }

  Future<bool> deleteNote(String noteId) async {
    try {
      String? token;
      if (Get.isRegistered<AuthController>()) {
        token = Get.find<AuthController>().currentUser.value?.token;
      }

      final response = await ApiService.delete('/notes/$noteId', token: token);

      if (response['success'] == true) {
        notes.removeWhere((n) => n.id == noteId);
        Get.snackbar(
          'Note Deleted 🗑️',
          response['message'] ?? 'Note was permanently removed.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.card,
          colorText: AppColors.white,
          margin: const EdgeInsets.all(16),
        );
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Delete Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.pinkLight,
        colorText: AppColors.magenta,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
  }
}
