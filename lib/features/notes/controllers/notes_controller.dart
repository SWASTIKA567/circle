import 'package:get/get.dart';

class NotesController extends GetxController {
  final RxString selectedCategory = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final RxList<Map<String, String>> notes = <Map<String, String>>[].obs;

  final List<String> categories = [
    'All', 'Computer Science', 'Data Structures', 'OS', 'Networks', 'Mathematics'
  ];

  List<Map<String, String>> get filteredNotes {
    return notes.where((note) {
      final matchesCategory =
          selectedCategory.value == 'All' || note['subject'] == selectedCategory.value;
      final query = searchQuery.value.trim().toLowerCase();
      final matchesQuery = query.isEmpty ||
          (note['title'] ?? '').toLowerCase().contains(query) ||
          (note['subject'] ?? '').toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void selectCategory(String category) => selectedCategory.value = category;
  void updateSearch(String query) => searchQuery.value = query;
}
