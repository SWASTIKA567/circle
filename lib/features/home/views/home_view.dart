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

    Get.bottomSheet(
      SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grayFade(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 18),
              CircleAvatar(
                radius: 36,
                backgroundColor: isAdmin ? AppColors.card : AppColors.purpleLight,
                child: Text(
                  controller.getInitials(user?.name ?? 'User'),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isAdmin ? AppColors.purple : AppColors.card,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user?.name ?? 'Circle User',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text),
              ),
              const SizedBox(height: 2),
              Text(user?.email ?? '', style: const TextStyle(fontSize: 13, color: AppColors.gray)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isAdmin
                      ? AppColors.card
                      : isSocietyMember
                          ? AppColors.purpleLight
                          : AppColors.blueLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isAdmin
                      ? '⭐ System Administrator'
                      : isSocietyMember
                          ? '★ Verified Society Member'
                          : 'General Student',
                  style: TextStyle(
                    fontSize: 12,
                    color: isAdmin
                        ? AppColors.green
                        : isSocietyMember
                            ? AppColors.card
                            : AppColors.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Divider(color: AppColors.grayFade(0.15)),
              ListTile(
                leading: const Icon(Icons.badge_outlined, color: AppColors.card),
                title: const Text('Student / Admin ID', style: TextStyle(fontSize: 12, color: AppColors.gray)),
                subtitle: Text(
                  user?.studentNo.isNotEmpty == true ? user!.studentNo : 'N/A',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.shield_outlined, color: AppColors.card),
                title: const Text('Account Role', style: TextStyle(fontSize: 12, color: AppColors.gray)),
                subtitle: Text(
                  isAdmin ? 'Administrator (Full Review & Manage Rights)' : 'Student User',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text),
                ),
              ),
              if (isAdmin) ...[
                const SizedBox(height: 10),
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
              ],
              const SizedBox(height: 10),
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
                Icon(Icons.all_inclusive_rounded, color: AppColors.purple, size: 20),
                SizedBox(width: 6),
                Text(
                  'Circle',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                    fontSize: 18,
                    letterSpacing: 0.8,
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
