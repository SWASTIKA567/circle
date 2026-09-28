import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../controllers/notes_controller.dart';
import '../models/note_model.dart';

class NotesView extends GetView<NotesController> {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Search & Filters Header
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(bottom: BorderSide(color: AppColors.grayFade(0.12))),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Modern Minimal Search Input
                TextField(
                  controller: controller.searchController,
                  onChanged: controller.updateSearch,
                  style: const TextStyle(fontSize: 14, color: AppColors.text),
                  decoration: InputDecoration(
                    hintText: 'Search by title, subject, unit, semester...',
                    hintStyle: const TextStyle(color: AppColors.gray, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.gray),
                    suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: AppColors.gray, size: 20),
                            onPressed: controller.clearSearch,
                          )
                        : const SizedBox.shrink()),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.grayFade(0.15)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.grayFade(0.15)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.purple, width: 1.8),
                    ),
                  ),
                ),

                // Search Results Bar (when searching)
                Obx(() {
                  final isFiltered = controller.searchQuery.value.trim().isNotEmpty;
                  if (!isFiltered) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, size: 16, color: AppColors.gray),
                        const SizedBox(width: 6),
                        Text(
                          'Found ${controller.filteredNotes.length} note${controller.filteredNotes.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: controller.clearSearch,
                          child: const Text(
                            'Clear search',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.card,
                              fontWeight: FontWeight.w800,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // Notes List with RefreshIndicator
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.purple),
                );
              }

              final filteredNotes = controller.filteredNotes;
              if (filteredNotes.isEmpty) {
                return RefreshIndicator(
                  color: AppColors.card,
                  onRefresh: controller.fetchNotes,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.picture_as_pdf_outlined, size: 52, color: AppColors.gray),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              controller.searchQuery.value.trim().isNotEmpty
                                  ? 'No notes matching "${controller.searchQuery.value.trim()}"'
                                  : 'No notes uploaded yet',
                              style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tap "+ Upload Note" below to add PDF course materials.',
                              style: TextStyle(color: AppColors.gray, fontSize: 13),
                            ),
                            if (controller.searchQuery.value.trim().isNotEmpty) ...[
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.card,
                                  side: const BorderSide(color: AppColors.card),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.refresh_rounded, size: 16),
                                label: const Text('Clear Search'),
                                onPressed: controller.clearSearch,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.card,
                onRefresh: controller.fetchNotes,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  itemCount: filteredNotes.length,
                  itemBuilder: (context, index) {
                    final note = filteredNotes[index];
                    return _buildNoteCard(note);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.upload_file_rounded, color: AppColors.purple),
        label: const Text('Upload Note', style: TextStyle(fontWeight: FontWeight.w700)),
        onPressed: () => _showUploadBottomSheet(context),
      ),
    );
  }

  Widget _buildNoteCard(NoteModel note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grayFade(0.12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                    color: AppColors.pinkLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.magenta, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'By ${note.author} • ${note.pages}',
                        style: const TextStyle(fontSize: 12, color: AppColors.gray),
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
                    color: AppColors.blueLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    note.subject,
                    style: const TextStyle(fontSize: 11, color: AppColors.text, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.purpleLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    note.unit,
                    style: const TextStyle(fontSize: 11, color: AppColors.card, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    note.semester,
                    style: const TextStyle(fontSize: 11, color: AppColors.gray, fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.card,
                    side: BorderSide(color: AppColors.grayFade(0.3)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.visibility_rounded, size: 15),
                  label: const Text('View', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  onPressed: () => controller.openNotePdf(note),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.card,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.download_rounded, size: 15),
                  label: const Text('Download', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  onPressed: () => controller.downloadNotePdf(note),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUploadBottomSheet(BuildContext context) {
    final titleController = TextEditingController();
    final unitController = TextEditingController(text: 'Unit 1');
    final selectedSubject = 'Computer Science'.obs;
    final selectedSemester = 'Semester 1'.obs;
    final Rx<File?> pickedFile = Rx<File?>(null);
    final RxString pickedFileName = ''.obs;
    final RxString pickedFileSize = ''.obs;

    final subjects = [
      'Computer Science',
      'Data Structures',
      'OS',
      'Networks',
      'Mathematics',
      'General',
    ];

    final semesters = [
      'Semester 1',
      'Semester 2',
      'Semester 3',
      'Semester 4',
      'Semester 5',
      'Semester 6',
      'Semester 7',
      'Semester 8',
    ];

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grayFade(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.upload_file_rounded, color: AppColors.purple, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Upload Note (PDF)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // PDF File Picker Box
              Obx(() {
                final hasFile = pickedFile.value != null;
                return InkWell(
                  onTap: () async {
                    try {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf'],
                      );
                      if (result != null && result.files.single.path != null) {
                        final path = result.files.single.path!;
                        pickedFile.value = File(path);
                        pickedFileName.value = result.files.single.name;
                        final bytes = result.files.single.size;
                        final mb = (bytes / (1024 * 1024)).toStringAsFixed(1);
                        pickedFileSize.value = '$mb MB';

                        if (titleController.text.trim().isEmpty) {
                          titleController.text = result.files.single.name.replaceAll('.pdf', '');
                        }
                      }
                    } catch (e) {
                      Get.snackbar(
                        'File Picker Error',
                        'Failed to pick PDF file: $e',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.pinkLight,
                        colorText: AppColors.magenta,
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: hasFile ? AppColors.purpleLight.withValues(alpha: 0.3) : AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: hasFile ? AppColors.card : AppColors.grayFade(0.2),
                        width: hasFile ? 1.8 : 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: hasFile ? AppColors.pinkLight : AppColors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            hasFile ? Icons.picture_as_pdf_rounded : Icons.add_circle_outline_rounded,
                            color: hasFile ? AppColors.magenta : AppColors.card,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hasFile ? pickedFileName.value : 'Tap to select PDF file',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: hasFile ? FontWeight.w700 : FontWeight.w600,
                                  color: hasFile ? AppColors.text : AppColors.card,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Supports standard PDF files up to 50MB',
                                style: TextStyle(fontSize: 12, color: AppColors.gray),
                              ),
                            ],
                          ),
                        ),
                        if (hasFile)
                          IconButton(
                            icon: const Icon(Icons.change_circle_outlined, color: AppColors.card),
                            onPressed: () => pickedFile.value = null,
                          ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),

              // Title input
              const Text(
                'Note Title',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: titleController,
                style: const TextStyle(fontSize: 14, color: AppColors.text),
                decoration: InputDecoration(
                  hintText: 'e.g. Operating Systems Chapter 3 Notes',
                  hintStyle: const TextStyle(color: AppColors.gray, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grayFade(0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grayFade(0.2)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.purple, width: 1.6),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Unit Name input
              const Text(
                'Unit Name',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: unitController,
                style: const TextStyle(fontSize: 14, color: AppColors.text),
                decoration: InputDecoration(
                  hintText: 'e.g. Unit 1, Unit 2 - Process Scheduling',
                  hintStyle: const TextStyle(color: AppColors.gray, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grayFade(0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grayFade(0.2)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.purple, width: 1.6),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Quick Unit selection chips
              Wrap(
                spacing: 8,
                children: ['Unit 1', 'Unit 2', 'Unit 3', 'Unit 4', 'Unit 5'].map((u) {
                  return InkWell(
                    onTap: () {
                      unitController.text = u;
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.purpleLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.purple.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        u,
                        style: const TextStyle(fontSize: 11, color: AppColors.card, fontWeight: FontWeight.w700),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Subject & Semester Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Subject',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text),
                        ),
                        const SizedBox(height: 6),
                        Obx(() => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.grayFade(0.2)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedSubject.value,
                              isExpanded: true,
                              items: subjects
                                  .map((s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s, style: const TextStyle(fontSize: 13, color: AppColors.text), overflow: TextOverflow.ellipsis),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) selectedSubject.value = val;
                              },
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Semester',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text),
                        ),
                        const SizedBox(height: 6),
                        Obx(() => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.grayFade(0.2)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedSemester.value,
                              isExpanded: true,
                              items: semesters
                                  .map((sem) => DropdownMenuItem(
                                        value: sem,
                                        child: Text(sem, style: const TextStyle(fontSize: 13, color: AppColors.text), overflow: TextOverflow.ellipsis),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) selectedSemester.value = val;
                              },
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Upload Action Button
              Obx(() => SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.card,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: controller.isUploading.value
                      ? null
                      : () async {
                          if (pickedFile.value == null) {
                            Get.snackbar(
                              'File Required',
                              'Please select a PDF file to upload.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors.pinkLight,
                              colorText: AppColors.magenta,
                            );
                            return;
                          }

                          if (titleController.text.trim().isEmpty) {
                            Get.snackbar(
                              'Title Required',
                              'Please enter a title for the note.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors.pinkLight,
                              colorText: AppColors.magenta,
                            );
                            return;
                          }

                          final success = await controller.uploadNote(
                            file: pickedFile.value!,
                            title: titleController.text.trim(),
                            subject: selectedSubject.value,
                            semester: selectedSemester.value,
                            unit: unitController.text.trim().isEmpty ? 'Unit 1' : unitController.text.trim(),
                          );

                          if (success) {
                            Get.back();
                          }
                        },
                  child: controller.isUploading.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: AppColors.purple,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_rounded, size: 20, color: AppColors.purple),
                            SizedBox(width: 8),
                            Text('Upload Note', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          ],
                        ),
                ),
              )),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
