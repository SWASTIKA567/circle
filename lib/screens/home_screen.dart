import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  final AuthService authService;

  const HomeScreen({super.key, required this.authService});

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return 'C';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    const primaryIndigo = Colors.indigo;
    final isSocietyMember = user?.isSocietyMember ?? false;

    return Scaffold(
      backgroundColor: Colors.indigo.shade50.withValues(alpha: 0.35),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.all_inclusive_rounded, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              'Circle',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        backgroundColor: primaryIndigo,
        elevation: 2,
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign Out', style: TextStyle(color: primaryIndigo, fontWeight: FontWeight.bold)),
                  content: const Text('Are you sure you want to sign out of Circle?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryIndigo,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await authService.logout();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // Profile Card
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: Colors.indigo.shade100, width: 1),
                ),
                child: Column(
                  children: [
                    // Avatar with user initials
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: primaryIndigo,
                      child: Text(
                        _getInitials(user?.name ?? 'User'),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // User Name
                    Text(
                      user?.name ?? 'Circle User',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // User Email
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Badges Row (Society Member Badge + DB Status)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        // Society Member Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSocietyMember ? primaryIndigo : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSocietyMember ? primaryIndigo : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSocietyMember ? Icons.groups_rounded : Icons.person_outline,
                                size: 16,
                                color: isSocietyMember ? Colors.white : Colors.grey.shade700,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isSocietyMember ? 'Society Member' : 'General Student',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSocietyMember ? Colors.white : Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Connected Status Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.indigo.shade200),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, size: 14, color: Colors.green),
                              SizedBox(width: 6),
                              Text(
                                'Express & MongoDB',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: primaryIndigo,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Details section
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.indigo.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Student Credentials',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryIndigo,
                      ),
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      icon: Icons.badge_outlined,
                      label: 'Student Number',
                      value: user?.studentNo.isNotEmpty == true ? user!.studentNo : 'N/A',
                    ),
                    const SizedBox(height: 14),
                    _buildDetailRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: user?.email ?? 'N/A',
                    ),
                    const SizedBox(height: 14),
                    _buildDetailRow(
                      icon: Icons.groups_outlined,
                      label: 'Society Status',
                      value: isSocietyMember ? 'Registered Society Member' : 'Not a Member',
                    ),
                    const SizedBox(height: 14),
                    _buildDetailRow(
                      icon: Icons.fingerprint_rounded,
                      label: 'Account ID',
                      value: user?.id ?? 'N/A',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Sign Out Button
              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryIndigo,
                    side: const BorderSide(color: primaryIndigo, width: 1.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text(
                    'Sign Out of Circle',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => authService.logout(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.indigo.shade400),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
