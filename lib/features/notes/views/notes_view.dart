import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notes_controller.dart';

class NotesView extends GetView<NotesController> {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryIndigo = Colors.indigo;
    final searchController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Search & Filters Header
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.indigo.shade50)),
            ),
            child: Column(
              children: [
                Obx(() => TextField(
                  controller: searchController,
                  onChanged: controller.updateSearch,
                  decoration: InputDecoration(
                    hintText: 'Search college notes, subjects...',
                    hintStyle: TextStyle(color: Colors.indigo.shade200, fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded, color: primaryIndigo),
                    suffixIcon: controller.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              searchController.clear();
                              controller.updateSearch('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.indigo.shade50.withValues(alpha: 0.35),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.indigo.shade100),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.indigo.shade100),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: primaryIndigo, width: 1.8),
                    ),
                  ),
                )),
                const SizedBox(height: 12),

                // Category Chips
                Obx(() => SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = controller.categories[index];
                      final isSelected = controller.selectedCategory.value == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : primaryIndigo,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        selectedColor: primaryIndigo,
                        backgroundColor: Colors.indigo.shade50.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: isSelected ? primaryIndigo : Colors.indigo.shade100),
                        ),
                        showCheckmark: false,
                        onSelected: (selected) {
                          if (selected) controller.selectCategory(cat);
                        },
                      );
                    },
                  ),
                )),
              ],
            ),
          ),

          // Notes List
          Expanded(
            child: Obx(() {
              final filteredNotes = controller.filteredNotes;
              if (filteredNotes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book_outlined, size: 56, color: Colors.indigo.shade200),
                      const SizedBox(height: 12),
                      Text(
                        controller.searchQuery.value.trim().isNotEmpty
                            ? 'No notes matching "${controller.searchQuery.value.trim()}"'
                            : (controller.selectedCategory.value == 'All'
                                ? 'No notes uploaded yet'
                                : 'No notes found for "${controller.selectedCategory.value}"'),
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Handnotes and PDFs will appear here once uploaded.',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                itemCount: filteredNotes.length,
                itemBuilder: (context, index) {
                  final item = filteredNotes[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.indigo.shade100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigo.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.picture_as_pdf_rounded, color: primaryIndigo, size: 26),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'] ?? '',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'By ${item['author']} • ${item['pages']}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item['subject'] ?? '',
                                  style: const TextStyle(fontSize: 11, color: primaryIndigo, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item['semester'] ?? '',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                                ),
                              ),
                              const Spacer(),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryIndigo,
                                  side: const BorderSide(color: primaryIndigo),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.download_rounded, size: 16),
                                label: const Text('Download', style: TextStyle(fontSize: 12)),
                                onPressed: () {
                                  Get.snackbar(
                                    'Downloading',
                                    'Downloading "${item['title']}"...',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.indigo.shade50,
                                    colorText: Colors.indigo.shade900,
                                    margin: const EdgeInsets.all(16),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryIndigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Upload Note', style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () {
          Get.snackbar(
            'Coming Soon',
            'Upload Note feature coming up!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.indigo.shade50,
            colorText: Colors.indigo.shade900,
            margin: const EdgeInsets.all(16),
          );
        },
      ),
    );
  }
}
