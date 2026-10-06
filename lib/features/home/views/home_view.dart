import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_theme.dart';
import '../controllers/home_controller.dart';
import '../../events/views/events_view.dart';
import '../../notes/views/notes_view.dart';
import '../../chatbot/views/chatbot_view.dart';
import '../../societies/views/societies_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  void _showProfileModal(BuildContext context) {
    final user = controller.authController.currentUser.value;
    final isSocietyMember = user?.isSocietyMember ?? false;
    final isAdmin = user?.isAdmin == true || user?.role == 'admin';

    Widget buildInfoTile(IconData icon, String title, String? value) {
      if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.card),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 11, color: AppColors.gray, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget buildSectionCard(String title, IconData sectionIcon, List<Widget> children) {
      final validChildren = children.where((w) => w is! SizedBox).toList();
      if (validChildren.isEmpty) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
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
            Row(
              children: [
                Icon(sectionIcon, size: 16, color: AppColors.purple),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...validChildren,
          ],
        ),
      );
    }

    Get.bottomSheet(
      SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grayFade(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),

              // Scrollable Profile Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: [
                    // Header Avatar & Identity
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.purple.withValues(alpha: 0.4), width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 38,
                              backgroundColor: isAdmin ? AppColors.card : AppColors.purpleLight,
                              child: Text(
                                controller.getInitials(user?.name ?? 'User'),
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: isAdmin ? AppColors.purple : AppColors.card,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user?.name ?? 'Circle User',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(fontSize: 13, color: AppColors.gray, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            alignment: WrapAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isAdmin
                                      ? AppColors.card
                                      : isSocietyMember
                                          ? AppColors.purpleLight
                                          : AppColors.blueLight,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  isAdmin
                                      ? '⭐ Administrator'
                                      : isSocietyMember
                                          ? '★ Society Member'
                                          : 'Verified Student',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isAdmin
                                        ? AppColors.green
                                        : isSocietyMember
                                            ? AppColors.card
                                            : AppColors.text,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (user?.branch != null && user!.branch!.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.grayFade(0.2)),
                                  ),
                                  child: Text(
                                    user.branch!,
                                    style: const TextStyle(fontSize: 11, color: AppColors.text, fontWeight: FontWeight.w700),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 1: Academic & College ERP
                    buildSectionCard(
                      'ACADEMIC PROFILE',
                      Icons.school_outlined,
                      [
                        buildInfoTile(Icons.badge_outlined, 'Student / Admission No.', user?.admissionNo ?? user?.studentNo),
                        buildInfoTile(Icons.menu_book_outlined, 'Course & Branch', '${user?.course ?? ""} ${user?.branch != null ? "• ${user!.branch!}" : ""}'.trim()),
                        buildInfoTile(Icons.grid_view_rounded, 'Current Semester', user?.semester),
                        buildInfoTile(Icons.mail_outline_rounded, 'AKGEC College Email', user?.email),
                        buildInfoTile(
                          Icons.groups_outlined,
                          'Campus Society Role',
                          user?.isSocietyMember == true ? '★ Verified Society Member' : 'Regular Student',
                        ),
                      ],
                    ),

                    // Section 2: Personal Details
                    buildSectionCard(
                      'PERSONAL DETAILS',
                      Icons.person_outline_rounded,
                      [
                        buildInfoTile(Icons.phone_outlined, 'Mobile Number', user?.mobileNo),
                        buildInfoTile(Icons.cake_outlined, 'Date of Birth', user?.dob),
                        buildInfoTile(Icons.water_drop_outlined, 'Blood Group', user?.bloodGroup),
                        buildInfoTile(Icons.home_outlined, 'Address', user?.address),
                      ],
                    ),

                    // Society Role Switch Button
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.card,
                          side: BorderSide(color: AppColors.grayFade(0.2)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: Icon(
                          user?.isSocietyMember == true ? Icons.verified_rounded : Icons.groups_outlined,
                          size: 18,
                          color: user?.isSocietyMember == true ? AppColors.green : AppColors.card,
                        ),
                        label: Text(
                          user?.isSocietyMember == true
                              ? 'Change Role (Currently Society Member)'
                              : 'Become a Society Member / Coordinator',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Get.back();
                          controller.authController.showSocietyMemberPrompt();
                        },
                      ),
                    ),


                    // Admin Shortcut
                    if (isAdmin) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.card,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.admin_panel_settings_rounded, size: 20, color: AppColors.purple),
                          label: const Text('Open Admin Panel', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () {
                            Get.back();
                            Get.toNamed(Routes.ADMIN);
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Sign Out Action
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.pink,
                          side: BorderSide(color: AppColors.pink.withValues(alpha: 0.6)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.logout_rounded, size: 20, color: AppColors.pink),
                        label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
                        onPressed: () {
                          Get.back();
                          Get.dialog(
                            AlertDialog(
                              backgroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              title: const Text('Sign Out', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                              content: const Text('Are you sure you want to sign out of Circle?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('Cancel', style: TextStyle(color: AppColors.gray)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.card, foregroundColor: AppColors.white),
                                  onPressed: () {
                                    Get.back();
                                    controller.authController.logout();
                                  },
                                  child: const Text('Sign Out'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = const [
      EventsView(),
      NotesView(),
      ChatbotView(),
      SocietiesView(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        title: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                ClipOval(
                  child: Image(
                    image: AssetImage('assets/circle_logo.jpg'),
                    width: 22,
                    height: 22,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  'Circle',
                  style: TextStyle(
                    fontFamily: 'Chicle',
                    color: AppColors.white,
                    fontSize: 24,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            Text(
              controller.tabTitles[controller.currentIndex.value],
              style: TextStyle(
                fontSize: 12,
                color: AppColors.white.withValues(alpha: 0.6),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        )),
        actions: [
          // Admin quick button (VISIBLE ONLY FOR ADMINS)
          Obx(() {
            final user = controller.authController.currentUser.value;
            final isAdmin = user?.isAdmin == true || user?.role == 'admin';
            if (!isAdmin) return const SizedBox.shrink();

            return IconButton(
              icon: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.green),
              tooltip: 'Admin Management Panel',
              onPressed: () => Get.toNamed(Routes.ADMIN),
            );
          }),
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: GestureDetector(
              onTap: () => _showProfileModal(context),
              child: Obx(() {
                final user = controller.authController.currentUser.value;
                return CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.white,
                  child: Text(
                    controller.getInitials(user?.name ?? 'User'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.card),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: tabs,
      )),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
          border: Border(top: BorderSide(color: AppColors.grayFade(0.12))),
        ),
        child: SafeArea(
          top: false,
          maintainBottomViewPadding: true,
          child: Obx(() => NavigationBar(
            height: 64,
            elevation: 0,
            selectedIndex: controller.currentIndex.value,
            onDestinationSelected: (index) => controller.currentIndex.value = index,
            backgroundColor: AppColors.white,
            indicatorColor: AppColors.purpleLight,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: AppColors.gray),
                selectedIcon: Icon(Icons.home_rounded, color: AppColors.card),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined, color: AppColors.gray),
                selectedIcon: Icon(Icons.menu_book_rounded, color: AppColors.card),
                label: 'Notes',
              ),
              NavigationDestination(
                icon: Icon(Icons.smart_toy_outlined, color: AppColors.gray),
                selectedIcon: Icon(Icons.smart_toy_rounded, color: AppColors.card),
                label: 'Chatbot',
              ),
              NavigationDestination(
                icon: Icon(Icons.groups_outlined, color: AppColors.gray),
                selectedIcon: Icon(Icons.groups_rounded, color: AppColors.card),
                label: 'Societies',
              ),
            ],
          )),
        ),
      ),
    );
  }
}
