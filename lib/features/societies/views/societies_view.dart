import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/societies_controller.dart';
import '../../auth/controllers/auth_controller.dart';

class SocietiesView extends GetView<SocietiesController> {
  const SocietiesView({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryIndigo = Colors.indigo;
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;
    final isSocietyMember = user?.isSocietyMember ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        final filteredSocieties = controller.filteredSocieties;
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          children: [
            // Member Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSocietyMember
                      ? [Colors.indigo.shade600, Colors.indigo.shade900]
                      : [Colors.indigo.shade50, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSocietyMember ? Colors.indigo.shade800 : Colors.indigo.shade100,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withValues(alpha: isSocietyMember ? 0.2 : 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: isSocietyMember
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.indigo.shade100,
                    child: Icon(
                      isSocietyMember ? Icons.verified_rounded : Icons.groups_rounded,
                      color: isSocietyMember ? Colors.white : primaryIndigo,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSocietyMember ? 'Verified Society Member' : 'Explore Campus Societies',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isSocietyMember ? Colors.white : primaryIndigo,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isSocietyMember
                              ? 'Student No: ${user?.studentNo ?? ''} • Active Member'
                              : 'Join clubs to participate in events and fests',
                          style: TextStyle(
                            fontSize: 12,
                            color: isSocietyMember
                                ? Colors.white.withValues(alpha: 0.85)
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Category Chips
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
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
            ),
            const SizedBox(height: 16),

            // Societies List
            if (filteredSocieties.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.groups_outlined, size: 56, color: Colors.indigo.shade200),
                    const SizedBox(height: 12),
                    Text(
                      controller.selectedCategory.value == 'All'
                          ? 'No societies listed yet'
                          : 'No societies found in "${controller.selectedCategory.value}"',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Campus clubs and student societies will appear here.',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  ],
                ),
              )
            else
              ...filteredSocieties.asMap().entries.map((entry) {
                final soc = entry.value;
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
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                soc['icon'] as IconData? ?? Icons.groups_rounded,
                                color: primaryIndigo,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    soc['name'] as String? ?? '',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${soc['category']} • ${soc['members']}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          soc['description'] as String? ?? '',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.3),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primaryIndigo,
                                side: const BorderSide(color: primaryIndigo),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                Get.snackbar(
                                  'Society Details',
                                  'Viewing ${soc['name']} details...',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.indigo.shade50,
                                  colorText: Colors.indigo.shade900,
                                  margin: const EdgeInsets.all(16),
                                );
                              },
                              child: const Text('View Society'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryIndigo,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                Get.snackbar(
                                  'Joined!',
                                  'Joined ${soc['name']}!',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green.shade50,
                                  colorText: Colors.green.shade900,
                                  margin: const EdgeInsets.all(16),
                                );
                              },
                              child: const Text('Join'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        );
      }),
    );
  }
}
