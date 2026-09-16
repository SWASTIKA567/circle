import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'tabs/chatbot_tab.dart';
import 'tabs/events_tab.dart';
import 'tabs/notes_tab.dart';
import 'tabs/societies_tab.dart';

class HomeScreen extends StatefulWidget {
  final AuthService authService;

  const HomeScreen({super.key, required this.authService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<String> _tabTitles = [
    'Home & Events',
    'College Notes',
    'Circle AI Assistant',
    'Campus Societies',
  ];

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return 'C';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  void _showProfileModal(BuildContext context) {
    final user = widget.authService.currentUser;
    const primaryIndigo = Colors.indigo;
    final isSocietyMember = user?.isSocietyMember ?? false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
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
                  backgroundColor: primaryIndigo,
                  child: Text(
                    _getInitials(user?.name ?? 'User'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.name ?? 'Circle User',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? '',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 14),

                // Society Status Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSocietyMember ? primaryIndigo : Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    isSocietyMember ? '★ Verified Society Member' : 'General Student',
                    style: TextStyle(
                      fontSize: 12,
                      color: isSocietyMember ? Colors.white : primaryIndigo,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.badge_outlined, color: primaryIndigo),
                  title: const Text('Student Number', style: TextStyle(fontSize: 13, color: Colors.grey)),
                  subtitle: Text(
                    user?.studentNo.isNotEmpty == true ? user!.studentNo : 'N/A',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.shield_outlined, color: primaryIndigo),
                  title: const Text('Auth Backend', style: TextStyle(fontSize: 13, color: Colors.grey)),
                  subtitle: const Text(
                    'Node.js Express + MongoDB',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ),
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
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (dCtx) => AlertDialog(
                          title: const Text('Sign Out', style: TextStyle(color: primaryIndigo, fontWeight: FontWeight.bold)),
                          content: const Text('Are you sure you want to sign out of Circle?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('Cancel')),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: primaryIndigo, foregroundColor: Colors.white),
                              onPressed: () => Navigator.pop(dCtx, true),
                              child: const Text('Sign Out'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await widget.authService.logout();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryIndigo = Colors.indigo;
    final user = widget.authService.currentUser;

    // EventsTab is the primary Home tab at index 0
    final tabs = [
      EventsTab(authService: widget.authService),
      const NotesTab(),
      const ChatbotTab(),
      SocietiesTab(authService: widget.authService),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryIndigo,
        elevation: 0,
        title: Column(
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
              _tabTitles[_currentIndex],
              style: TextStyle(
                fontSize: 12,
                color: Colors.indigo.shade100,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: GestureDetector(
              onTap: () => _showProfileModal(context),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Text(
                  _getInitials(user?.name ?? 'User'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: primaryIndigo,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: Container(
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
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
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
      ),
    );
  }
}
