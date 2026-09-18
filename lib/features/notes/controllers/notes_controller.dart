import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/api_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../models/note_model.dart';

class NotesController extends GetxController {
  final RxString selectedCategory = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final RxList<NoteModel> notes = <NoteModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;
  final RxString errorMessage = ''.obs;

  final List<String> categories = [
    'All',
    'Computer Science',
    'Data Structures',
    'OS',
    'Networks',
    'Mathematics',
    'General',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchNotes();
  }

  List<NoteModel> get filteredNotes {
    return notes.where((note) {
      final matchesCategory =
          selectedCategory.value == 'All' ||
          note.subject.toLowerCase() == selectedCategory.value.toLowerCase();

      final query = searchQuery.value.trim().toLowerCase();
      final matchesQuery = query.isEmpty ||
          note.title.toLowerCase().contains(query) ||
          note.subject.toLowerCase().contains(query) ||
          note.author.toLowerCase().contains(query);

      return matchesCategory && matchesQuery;
    }).toList();
  }

  void selectCategory(String category) => selectedCategory.value = category;
  void updateSearch(String query) => searchQuery.value = query;

  Future<void> fetchNotes() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await ApiService.get('/notes');

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
        notes.insert(0, newNote);

        Get.snackbar(
          'Upload Successful',
          '"${newNote.title}" has been uploaded successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.indigo.shade50,
          colorText: Colors.indigo.shade900,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
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
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
      return false;
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> openNotePdf(NoteModel note) async {
    if (note.fileUrl.isEmpty) {
      Get.snackbar(
        'Error',
        'PDF URL not available for this note.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final fullUrl = ApiService.resolveFileUrl(note.fileUrl);
    final uri = Uri.parse(fullUrl);

    try {
      final canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback with platform default mode
        await launchUrl(uri);
      }
    } catch (e) {
      Get.snackbar(
        'Could Not Open PDF',
        'Unable to open $fullUrl: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber.shade50,
        colorText: Colors.amber.shade900,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}
