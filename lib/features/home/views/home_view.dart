import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/home_controller.dart';
import '../../events/views/events_view.dart';
import '../../notes/views/notes_view.dart';
import '../../chatbot/views/chatbot_view.dart';
import '../../societies/views/societies_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  void _showProfileModal(BuildContext context) {
    final user = controller.authController.currentUser.value;
    const primaryIndigo = Colors.indigo;
    final isSocietyMember = user?.isSocietyMember ?? false;
    final isAdmin = user?.isAdmin == true || user?.role == 'admin';

    Get.bottomSheet(
      SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
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
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 18),
              CircleAvatar(
                radius: 36,
                backgroundColor: isAdmin ? Colors.amber.shade700 : primaryIndigo,
                child: Text(
                  controller.getInitials(user?.name ?? 'User'),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user?.name ?? 'Circle User',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
              ),
              const SizedBox(height: 2),
              Text(user?.email ?? '', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: isAdmin
                      ? Colors.amber.shade50
                      : isSocietyMember
                          ? primaryIndigo
                          : Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: isAdmin ? Border.all(color: Colors.amber.shade300) : null,
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
                        ? Colors.amber.shade900
                        : isSocietyMember
                            ? Colors.white
                            : primaryIndigo,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.badge_outlined, color: primaryIndigo),
                title: const Text('Student / Admin ID', style: TextStyle(fontSize: 13, color: Colors.grey)),
                subtitle: Text(
                  user?.studentNo.isNotEmpty == true ? user!.studentNo : 'N/A',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.shield_outlined, color: primaryIndigo),
                title: const Text('Account Role', style: TextStyle(fontSize: 13, color: Colors.grey)),
                subtitle: Text(
                  isAdmin ? 'Administrator (Full Review & Manage Rights)' : 'Student User',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ),
              if (isAdmin) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryIndigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.admin_panel_settings_rounded, size: 20),
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
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Get.back();
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Sign Out', style: TextStyle(color: primaryIndigo, fontWeight: FontWeight.bold)),
                        content: const Text('Are you sure you want to sign out of Circle?'),
                        actions: [
                          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: primaryIndigo, foregroundColor: Colors.white),
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
    const primaryIndigo = Colors.indigo;

    final tabs = const [
      EventsView(),
      NotesView(),
      ChatbotView(),
      SocietiesView(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryIndigo,
        elevation: 0,
        title: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.all_inclusive_rounded, color: Colors.white, size: 20),
                SizedBox(width: 6),
                Text(
                  'Circle',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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
                color: Colors.indigo.shade100,
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
              icon: const Icon(Icons.admin_panel_settings_rounded, color: Colors.amberAccent),
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
                  backgroundColor: Colors.white,
                  child: Text(
                    controller.getInitials(user?.name ?? 'User'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryIndigo),
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
      bottomNavigationBar: Obx(() => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
          border: Border(top: BorderSide(color: Colors.indigo.shade50)),
        ),
        child: NavigationBar(
          selectedIndex: controller.currentIndex.value,
          onDestinationSelected: (index) => controller.currentIndex.value = index,
          backgroundColor: Colors.white,
          indicatorColor: Colors.indigo.shade100,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: primaryIndigo),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book_rounded, color: primaryIndigo),
              label: 'Notes',
            ),
            NavigationDestination(
              icon: Icon(Icons.smart_toy_outlined),
              selectedIcon: Icon(Icons.smart_toy_rounded, color: primaryIndigo),
              label: 'Chatbot',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_outlined),
              selectedIcon: Icon(Icons.groups_rounded, color: primaryIndigo),
              label: 'Societies',
            ),
          ],
        ),
      )),
    );
  }
}
