import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
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
        societies.insert(0, newSociety);

        Get.snackbar(
          'Society Created!',
          '"${newSociety.name}" has been registered successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.indigo.shade50,
          colorText: Colors.indigo.shade900,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
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
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
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

      return response['success'] == true;
    } catch (e) {
      Get.snackbar(
        'Verification Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
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

        Get.snackbar(
          'Updated Successfully',
          '"${updatedSociety.name}" details updated successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.indigo.shade50,
          colorText: Colors.indigo.shade900,
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
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
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
        backgroundColor: Colors.amber.shade50,
        colorText: Colors.amber.shade900,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}
