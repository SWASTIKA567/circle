import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../controllers/attendance_controller.dart';
import '../models/attendance_model.dart';

class AttendanceView extends StatelessWidget {
  const AttendanceView({super.key});

  // Color Palette Constants:
  // Under 75% -> Red
  // 75% and above -> Dark Green
  static const Color darkGreen = Color(0xFF15803D);     // >= 75%: Dark Green
  static const Color darkGreenBg = Color(0xFFDCFCE7);   // Soft dark green tint
  static const Color dangerRed = Color(0xFFDC2626);     // < 75%: Red
  static const Color dangerRedBg = Color(0xFFFEE2E2);   // Soft red tint

  Color _getPercentageColor(double percentage) {
    return percentage >= 75.0 ? darkGreen : dangerRed;
  }

  Color _getPercentageBgColor(double percentage) {
    return percentage >= 75.0 ? darkGreenBg : dangerRedBg;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AttendanceController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.card),
                SizedBox(height: 16),
                Text(
                  'Fetching live attendance from ERP...',
                  style: TextStyle(color: AppColors.gray, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty && controller.attendance.value == null) {
          return RefreshIndicator(
            color: AppColors.card,
            onRefresh: () => controller.fetchAttendance(refresh: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.22),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: AppColors.purpleLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.school_outlined, size: 48, color: AppColors.card),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'ERP Attendance Sync',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: AppColors.gray, height: 1.4),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.card,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Retry Fetch', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () => controller.fetchAttendance(refresh: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final data = controller.attendance.value;
        if (data == null) {
          return const Center(child: Text('No attendance records available.'));
        }

        final overallColor = _getPercentageColor(data.overallPercentage);
        final overallBg = _getPercentageBgColor(data.overallPercentage);
        final isEligible = data.overallPercentage >= 75.0;

        return RefreshIndicator(
          color: AppColors.card,
          onRefresh: () => controller.fetchAttendance(refresh: true),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 1. Top Header Banner Card (matching Events & Notes palette)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(18),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.how_to_reg_rounded, color: AppColors.purple, size: 22),
                                SizedBox(width: 8),
                                Text(
                                  'Attendance Tracker',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.white,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.purpleLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'AKGEC LIVE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.card,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Live attendance synchronized directly from the AKGEC EduMarshal ERP portal.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.white.withValues(alpha: 0.72),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Overall Attendance Hero Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.grayFade(0.12)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Circular percentage indicator
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 86,
                                  height: 86,
                                  child: CircularProgressIndicator(
                                    value: (data.overallPercentage / 100).clamp(0.0, 1.0),
                                    strokeWidth: 9,
                                    backgroundColor: overallBg,
                                    color: overallColor,
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${data.overallPercentage.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: overallColor,
                                      ),
                                    ),
                                    const Text(
                                      'Overall',
                                      style: TextStyle(fontSize: 10, color: AppColors.gray, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: overallBg,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isEligible ? Icons.check_circle_rounded : Icons.warning_rounded,
                                          size: 14,
                                          color: overallColor,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          isEligible ? '75% Criteria Met' : 'Shortage Warning (<75%)',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: overallColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    isEligible
                                        ? 'Good standing in AKGEC attendance records.'
                                        : 'Required to maintain ≥ 75% for exam eligibility.',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.text,
                                      fontWeight: FontWeight.w600,
                                      height: 1.3,
                                    ),
                                  ),
                                  if (data.isFromCache) ...[
                                    const SizedBox(height: 4),
                                    const Text(
                                      '⚡ Showing cached data (Pull to refresh)',
                                      style: TextStyle(fontSize: 10, color: AppColors.gray, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 16),

                        // Stats Summary Row
                        Row(
                          children: [
                            _buildStatBox('Total Held', '${data.totalHeld}', AppColors.card, AppColors.blueLight),
                            const SizedBox(width: 10),
                            _buildStatBox('Present', '${data.totalPresent}', darkGreen, darkGreenBg),
                            const SizedBox(width: 10),
                            _buildStatBox('Absent', '${data.totalAbsent}', dangerRed, dangerRedBg),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. 75% Criteria Advisor / Planner Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isEligible
                          ? const Color(0xFFF0FDF4)
                          : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isEligible
                            ? const Color(0xFFBBF7D0)
                            : const Color(0xFFFECDD3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isEligible ? Icons.verified_user_rounded : Icons.schedule_rounded,
                          color: isEligible ? darkGreen : dangerRed,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEligible ? 'Attendance Margin' : 'Recovery Goal',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: isEligible ? darkGreen : dangerRed,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isEligible
                                    ? 'You can safely miss ${data.overallSafeBunk} ${data.overallSafeBunk == 1 ? 'class' : 'classes'} and still stay above 75%.'
                                    : 'Attend the next ${data.overallRequiredToAttend} ${data.overallRequiredToAttend == 1 ? 'class' : 'classes'} consecutively to achieve 75%.',
                                style: const TextStyle(fontSize: 12, color: AppColors.text, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. Search & Header Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subject-wise Records',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.text),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.grayFade(0.15)),
                            ),
                            child: Text(
                              '${data.subjects.length} Subjects',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.gray),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: controller.searchController,
                        onChanged: controller.updateSearch,
                        decoration: InputDecoration(
                          hintText: 'Search by subject name or code...',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.card, size: 20),
                          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: controller.clearSearch,
                                )
                              : const SizedBox.shrink()),
                          filled: true,
                          fillColor: AppColors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                            borderSide: const BorderSide(color: AppColors.card, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 5. Subject Cards List
              Obx(() {
                final subjects = controller.filteredSubjects;
                if (subjects.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          controller.searchQuery.value.isNotEmpty
                              ? 'No subject found matching "${controller.searchQuery.value}"'
                              : 'No subjects recorded.',
                          style: const TextStyle(color: AppColors.gray, fontSize: 13),
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final sub = subjects[index];
                        return _buildSubjectCard(sub);
                      },
                      childCount: subjects.length,
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatBox(String label, String value, Color textColor, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(AttendanceSubjectModel sub) {
    final statusColor = _getPercentageColor(sub.percentage);
    final statusBg = _getPercentageBgColor(sub.percentage);
    final isAbove75 = sub.percentage >= 75.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.grayFade(0.12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Subject Code & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (sub.subjectCode.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.purpleLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    sub.subjectCode,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.card,
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAbove75 ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      size: 13,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${sub.percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Subject Name
          Text(
            sub.subjectName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),

          if (sub.facultyName.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              sub.facultyName,
              style: const TextStyle(fontSize: 12, color: AppColors.gray, fontWeight: FontWeight.w500),
            ),
          ],
          const SizedBox(height: 12),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (sub.percentage / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: const Color(0xFFF1F5F9),
              color: statusColor,
            ),
          ),
          const SizedBox(height: 12),

          // Metrics & Advice footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attended: ${sub.present}/${sub.totalClasses} classes',
                style: const TextStyle(fontSize: 12, color: AppColors.text, fontWeight: FontWeight.w700),
              ),
              Text(
                isAbove75
                    ? (sub.safeBunk > 0 ? 'Can miss ${sub.safeBunk} classes' : 'Above 75%')
                    : (sub.requiredToAttend > 0 ? 'Attend next ${sub.requiredToAttend} classes' : 'Below 75%'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
