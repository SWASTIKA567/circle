import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/services/api_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../models/society_model.dart';

class SocietiesController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxString selectedCategory = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final RxList<SocietyModel> societies = <SocietyModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<String, String> unlockedSocieties = <String, String>{}.obs;

  bool isSocietyUnlocked(String societyId) => unlockedSocieties.containsKey(societyId);
  String? getSocietyPassword(String societyId) => unlockedSocieties[societyId];

  final List<String> categories = [
    'All',
    'Technical',
    'Cultural',
    'Literary',
    'Sports',
    'General',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchSocieties();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  List<SocietyModel> get filteredSocieties {
    return societies.where((soc) {
      final matchesCategory =
          selectedCategory.value == 'All' ||
          soc.category.toLowerCase() == selectedCategory.value.toLowerCase();

      final query = searchQuery.value.trim().toLowerCase();
      final matchesQuery = query.isEmpty ||
          soc.name.toLowerCase().contains(query) ||
          soc.department.toLowerCase().contains(query) ||
          soc.description.toLowerCase().contains(query) ||
          soc.domains.any((d) => d.toLowerCase().contains(query));

      return matchesCategory && matchesQuery;
    }).toList();
  }

  void selectCategory(String category) => selectedCategory.value = category;
  void updateSearch(String query) => searchQuery.value = query;

  DateTime? _parseEventDate(String dateStr) {
    if (dateStr.trim().isEmpty) return null;
    try {
      final parsed = DateTime.tryParse(dateStr.trim());
      if (parsed != null) return parsed;
      final parts = dateStr.trim().split(RegExp(r'[\s/\-]'));
      if (parts.length >= 3) {
        const months = {
          'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4,
          'may': 5, 'jun': 6, 'jul': 7, 'aug': 8,
          'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
        };
        final day = int.tryParse(parts[0]);
        final monthKey = parts[1].toLowerCase().substring(0, 3);
        final month = months[monthKey];
        final year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          return DateTime(year, month, day);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Returns upcoming events from all approved societies for the Home screen.
  /// Visible for maximum 2 days from the event date.
  List<Map<String, dynamic>> get societyEventsForHomeFeed {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<Map<String, dynamic>> feed = [];

    for (final soc in societies) {
      for (final evt in soc.upcomingEvents) {
        if (evt.title.isEmpty) continue;

        final eventDate = _parseEventDate(evt.date);
        if (eventDate != null) {
          final diffDays = eventDate.difference(today).inDays;
          // Only show on upcoming if between 0 and 2 days (max 2 days active window)
          if (diffDays < 0 || diffDays > 2) continue;
        }

        feed.add({
          'title': evt.title,
          'society': soc.name,
          'societyId': soc.id,
          'date': evt.date,
          'time': evt.time,
          'description': evt.description,
          'imageUrl': evt.imageUrl,
          'registrationLink': evt.registrationLink,
          'type': soc.category,
          'isRsvp': false,
          'source': 'society',
          'isPast': false,
        });
      }
    }

    return feed;
  }

  /// Returns past events from all societies (both explicit recentEvents and
  /// upcoming events that passed their 2-day home visibility window).
  List<Map<String, dynamic>> get societyPastEventsForHomeFeed {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<Map<String, dynamic>> feed = [];

    for (final soc in societies) {
      // 1. Explicit recent/past events
      for (final evt in soc.recentEvents) {
        if (evt.title.isEmpty) continue;
        feed.add({
          'title': evt.title,
          'society': soc.name,
          'societyId': soc.id,
          'date': evt.date,
          'time': evt.time,
          'description': evt.description,
          'imageUrl': evt.imageUrl,
          'registrationLink': evt.registrationLink,
          'type': soc.category,
          'isRsvp': false,
          'source': 'society',
          'isPast': true,
        });
      }

      // 2. Upcoming events that expired (> 2 days past or already completed)
      for (final evt in soc.upcomingEvents) {
        if (evt.title.isEmpty) continue;
        final eventDate = _parseEventDate(evt.date);
        if (eventDate != null) {
          final diffDays = eventDate.difference(today).inDays;
          if (diffDays < 0 || diffDays > 2) {
            feed.add({
              'title': evt.title,
              'society': soc.name,
              'societyId': soc.id,
              'date': evt.date,
              'time': evt.time,
              'description': evt.description,
              'imageUrl': evt.imageUrl,
              'registrationLink': evt.registrationLink,
              'type': soc.category,
              'isRsvp': false,
              'source': 'society',
              'isPast': true,
            });
          }
        }
      }
    }

    return feed;
  }
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  String? _getUserToken() {
    if (Get.isRegistered<AuthController>()) {
      return Get.find<AuthController>().currentUser.value?.token;
    }
    return null;
  }

  Future<void> fetchSocieties() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await ApiService.get('/societies');

      if (response['success'] == true && response['societies'] is List) {
        final List list = response['societies'];
        societies.value =
            list.map((e) => SocietyModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createSociety({
    required String name,
    required String department,
    required String description,
    required String societyPassword,
    String logoUrl = '',
    String websiteLink = '',
    String registrationLink = '',
    List<String> domains = const [],
    List<SocietyEventModel> recentEvents = const [],
    List<SocietyEventModel> upcomingEvents = const [],
    String category = 'Technical',
  }) async {
    try {
      isSubmitting.value = true;
      final token = _getUserToken();

      if (token == null || token.isEmpty) {
        throw Exception('Please sign in to create a society.');
      }

      final body = {
        'name': name.trim(),
        'department': department.trim(),
        'description': description.trim(),
        'societyPassword': societyPassword.trim(),
        'logoUrl': logoUrl.trim(),
        'websiteLink': websiteLink.trim(),
        'registrationLink': registrationLink.trim(),
        'domains': domains,
        'recentEvents': recentEvents.map((e) => e.toJson()).toList(),
        'upcomingEvents': upcomingEvents.map((e) => e.toJson()).toList(),
        'category': category,
      };

      final response = await ApiService.post('/societies', body, token: token);

      if (response['success'] == true && response['society'] != null) {
        final newSociety = SocietyModel.fromJson(response['society']);
        if (newSociety.isApproved) {
          societies.insert(0, newSociety);
        }

        Get.snackbar(
          'Submitted for Approval 📋',
          response['message'] ?? '"${newSociety.name}" registered! It will be visible after Admin approval.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.card,
          colorText: AppColors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        );
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to create society.');
      }
    } catch (e) {
      Get.snackbar(
        'Creation Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.pinkLight,
        colorText: AppColors.magenta,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> verifySocietyPassword(String societyId, String password) async {
    try {
      final token = _getUserToken();
      if (token == null) throw Exception('Please log in first.');

      final response = await ApiService.post(
        '/societies/$societyId/verify-password',
        {'password': password.trim()},
        token: token,
      );

      final success = response['success'] == true;
      if (success) {
        unlockedSocieties[societyId] = password.trim();
      }
      return success;
    } catch (e) {
      Get.snackbar(
        'Verification Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.pinkLight,
        colorText: AppColors.magenta,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
  }

  Future<bool> updateSociety({
    required String societyId,
    required String societyPassword,
    String? name,
    String? department,
    String? description,
    String? logoUrl,
    String? websiteLink,
    String? registrationLink,
    List<String>? domains,
    List<SocietyEventModel>? recentEvents,
    List<SocietyEventModel>? upcomingEvents,
    String? category,
    String? newSocietyPassword,
  }) async {
    try {
      isSubmitting.value = true;
      final token = _getUserToken();

      if (token == null || token.isEmpty) {
        throw Exception('Please sign in to update society.');
      }

      final Map<String, dynamic> body = {
        'societyPassword': societyPassword.trim(),
      };

      if (name != null) body['name'] = name.trim();
      if (department != null) body['department'] = department.trim();
      if (description != null) body['description'] = description.trim();
      if (logoUrl != null) body['logoUrl'] = logoUrl.trim();
      if (websiteLink != null) body['websiteLink'] = websiteLink.trim();
      if (registrationLink != null) body['registrationLink'] = registrationLink.trim();
      if (domains != null) body['domains'] = domains;
      if (recentEvents != null) {
        body['recentEvents'] = recentEvents.map((e) => e.toJson()).toList();
      }
      if (upcomingEvents != null) {
        body['upcomingEvents'] = upcomingEvents.map((e) => e.toJson()).toList();
      }
      if (category != null) body['category'] = category;
      if (newSocietyPassword != null && newSocietyPassword.trim().isNotEmpty) {
        body['newSocietyPassword'] = newSocietyPassword.trim();
      }

      // Using ApiService.post or HTTP put for update
      final response = await ApiService.put(
        '/societies/$societyId',
        body,
        token: token,
      );

      if (response['success'] == true && response['society'] != null) {
        final updatedSociety = SocietyModel.fromJson(response['society']);
        final index = societies.indexWhere((s) => s.id == societyId);
        if (index != -1) {
          societies[index] = updatedSociety;
        } else {
          fetchSocieties();
        }

        if (newSocietyPassword != null && newSocietyPassword.trim().isNotEmpty) {
          unlockedSocieties[societyId] = newSocietyPassword.trim();
        } else {
          unlockedSocieties[societyId] = societyPassword.trim();
        }

        Get.snackbar(
          'Updated Successfully',
          '"${updatedSociety.name}" details updated successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.card,
          colorText: AppColors.white,
          margin: const EdgeInsets.all(16),
        );
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to update society.');
      }
    } catch (e) {
      Get.snackbar(
        'Update Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.pinkLight,
        colorText: AppColors.magenta,
        margin: const EdgeInsets.all(16),
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> launchExternalUrl(String url) async {
    if (url.trim().isEmpty) return;

    var formatted = url.trim();
    if (!formatted.startsWith('http://') && !formatted.startsWith('https://')) {
      formatted = 'https://$formatted';
    }

    final uri = Uri.parse(formatted);
    try {
      final can = await canLaunchUrl(uri);
      if (can) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      Get.snackbar(
        'Could Not Open Link',
        'Unable to open $url: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.card,
        colorText: AppColors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}
