import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../controllers/notes_controller.dart';
import '../models/note_model.dart';

class NotesView extends GetView<NotesController> {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isInsideSemester = controller.currentSemester.value != null;

      return PopScope(
        canPop: !isInsideSemester,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && isInsideSemester) {
            controller.exitSemester();
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: isInsideSemester
              ? _buildInsideSemesterView(context)
              : _buildSemesterBoxesView(context),
          floatingActionButton: isInsideSemester
              ? FloatingActionButton.extended(
                  backgroundColor: AppColors.card,
                  foregroundColor: AppColors.white,
                  icon: const Icon(Icons.upload_file_rounded, color: AppColors.purple),
                  label: const Text('Upload Note', style: TextStyle(fontWeight: FontWeight.w700)),
                  onPressed: () => _showUploadBottomSheet(context),
                )
              : null,
        ),
      );
    });
  }

  /// 8 Semester boxes view
  Widget _buildSemesterBoxesView(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      children: [
        // Greeting Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.school_rounded, color: AppColors.purple, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Semester Notes',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Select your semester below to view syllabus notes, course units, and student materials.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.white.withValues(alpha: 0.7),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Section Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Select Semester',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.text),
            ),
            Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.grayFade(0.15)),
              ),
              child: Text(
                '${controller.notes.length} Total Notes',
                style: const TextStyle(fontSize: 11, color: AppColors.gray, fontWeight: FontWeight.w600),
              ),
            )),
          ],
        ),
        const SizedBox(height: 14),

        // 8 Semester Boxes Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.15,
          ),
          itemCount: controller.semesterBoxes.length,
          itemBuilder: (context, index) {
            final sem = controller.semesterBoxes[index];
            final key = sem['key']!;
            final title = sem['title']!;
            final code = sem['code']!;

            return Obx(() {
              final count = controller.countForSemester(key);

              return InkWell(
                onTap: () => controller.enterSemester(key),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.grayFade(0.12)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row: Code Badge + Icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.purpleLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              code,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.card,
                              ),
                            ),
                          ),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              size: 16,
                              color: AppColors.card,
                            ),
                          ),
                        ],
                      ),

                      // Semester Name + Count
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$count note${count == 1 ? '' : 's'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.gray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      // Enter Link
                      const Row(
                        children: [
                          Text(
                            'Enter',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.card,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: AppColors.card,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            });
          },
        ),
      ],
    );
  }

  /// Inside semester view with Back Button, Search, and Notes list
  Widget _buildInsideSemesterView(BuildContext context) {
    final semKey = controller.currentSemester.value!;
    final semInfo = controller.semesterBoxes.firstWhere(
      (s) => s['key'] == semKey,
      orElse: () => {'title': semKey, 'code': semKey},
    );
    final title = semInfo['title'] ?? semKey;

    return Column(
      children: [
        // Inside Semester Top Bar with Back Button
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border(bottom: BorderSide(color: AppColors.grayFade(0.12))),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: controller.exitSemester,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.grayFade(0.15)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.card),
                      SizedBox(width: 4),
                      Text(
                        'Semesters',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.card),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.purpleLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${controller.filteredNotes.length} Notes',
                  style: const TextStyle(fontSize: 11, color: AppColors.card, fontWeight: FontWeight.bold),
                ),
              )),
            ],
          ),
        ),

        // Search within this semester
        Container(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
          color: AppColors.white,
          child: TextField(
            controller: controller.searchController,
            onChanged: controller.updateSearch,
            style: const TextStyle(fontSize: 14, color: AppColors.text),
            decoration: InputDecoration(
              hintText: 'Search $title by title, subject, unit...',
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
        ),

        // Notes List with RefreshIndicator
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.purple),
              );
            }

            if (controller.errorMessage.value.isNotEmpty) {
              return RefreshIndicator(
                color: AppColors.card,
                onRefresh: controller.fetchNotes,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.16),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/no_network_dog.svg',
                            height: 140,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Connection Issue',
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              controller.errorMessage.value.contains('timed out') ||
                                      controller.errorMessage.value.contains('SocketException')
                                  ? 'Unable to reach the campus server. Check your connection.'
                                  : controller.errorMessage.value,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.gray, fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.card,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text('Try Again'),
                            onPressed: controller.fetchNotes,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                    SizedBox(height: MediaQuery.of(context).size.height * 0.14),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/no_events_dog.svg',
                            height: 140,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            controller.searchQuery.value.trim().isNotEmpty
                                ? 'No notes matching "${controller.searchQuery.value.trim()}"'
                                : 'No notes in $title yet',
                            style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            controller.searchQuery.value.trim().isNotEmpty
                                ? 'Try searching by a different term or subject.'
                                : 'Be the first to upload course materials for $title!\nTap "+ Upload Note" below to get started.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.gray, fontSize: 13),
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
    final subjectController = TextEditingController();
    final unitController = TextEditingController(text: 'Unit 1');
    final selectedSemester = (controller.currentSemester.value ??
            (controller.selectedCategory.value != 'All'
                ? controller.selectedCategory.value
                : 'Semester 1'))
        .obs;
    final Rx<File?> pickedFile = Rx<File?>(null);
    final RxString pickedFileName = ''.obs;
    final RxString pickedFileSize = ''.obs;

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
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.purple, width: 1.6),
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
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.purple, width: 1.6),
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

  static void showSemestersModal(BuildContext context, NotesController controller) {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grayFade(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.school_rounded, color: AppColors.card, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Semester Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  Obx(
                    () => controller.selectedCategory.value != 'All'
                        ? TextButton(
                            onPressed: () {
                              controller.selectCategory('All');
                              Get.back();
                            },
                            child: const Text(
                              'Reset to All',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.card,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Select a semester to explore or upload syllabus notes',
                style: TextStyle(fontSize: 12, color: AppColors.gray),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: controller.categories.map((cat) {
                      return Obx(() {
                        final isSelected = controller.selectedCategory.value == cat;
                        final count = controller.countForCategory(cat);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.purpleLight
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.card
                                  : AppColors.grayFade(0.12),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 2,
                            ),
                            leading: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.card
                                    : AppColors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: cat == 'All'
                                  ? Icon(
                                      Icons.grid_view_rounded,
                                      color: isSelected
                                          ? AppColors.white
                                          : AppColors.gray,
                                      size: 18,
                                    )
                                  : Text(
                                      cat.replaceAll('Semester ', 'S'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: isSelected
                                            ? AppColors.purple
                                            : AppColors.text,
                                      ),
                                    ),
                            ),
                            title: Text(
                              cat == 'All' ? 'All Semesters' : cat,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isSelected
                                    ? AppColors.card
                                    : AppColors.text,
                              ),
                            ),
                            subtitle: Text(
                              '$count note${count == 1 ? '' : 's'}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected
                                    ? AppColors.card.withValues(alpha: 0.8)
                                    : AppColors.gray,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.card,
                                    size: 22,
                                  )
                                : const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.gray,
                                    size: 20,
                                  ),
                            onTap: () {
                              controller.selectCategory(cat);
                              Get.back();
                            },
                          ),
                        );
                      });
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
