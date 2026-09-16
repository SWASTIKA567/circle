import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class SocietiesTab extends StatefulWidget {
  final AuthService authService;

  const SocietiesTab({super.key, required this.authService});

  @override
  State<SocietiesTab> createState() => _SocietiesTabState();
}

class _SocietiesTabState extends State<SocietiesTab> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Technical',
    'Cultural',
    'Literary',
    'Sports',
  ];

  final List<Map<String, dynamic>> _societies = [
    {
      'name': 'Google Developer Student Club',
      'category': 'Technical',
      'members': '140+ Members',
      'description':
          'Fostering peer-to-peer learning in mobile, web, and cloud technologies.',
      'icon': Icons.code_rounded,
      'isJoined': true,
    },
    {
      'name': 'Robotics & Automation Society',
      'category': 'Technical',
      'members': '95+ Members',
      'description':
          'Hands-on robotics hardware, IoT builds, and competitive bot challenges.',
      'icon': Icons.precision_manufacturing_rounded,
      'isJoined': false,
    },
    {
      'name': 'Cadence Music & Bands',
      'category': 'Cultural',
      'members': '75+ Members',
      'description':
          'Vocalists, instrumentalists, and live performances across college fests.',
      'icon': Icons.music_note_rounded,
      'isJoined': false,
    },
    {
      'name': 'Orators Debating Society',
      'category': 'Literary',
      'members': '50+ Members',
      'description':
          'Parliamentary debates, Model UN simulations, and public speaking workshops.',
      'icon': Icons.record_voice_over_rounded,
      'isJoined': false,
    },
    {
      'name': 'Vanguard Sports Council',
      'category': 'Sports',
      'members': '120+ Members',
      'description':
          'Inter-college tournaments for football, cricket, basketball, and badminton.',
      'icon': Icons.sports_soccer_rounded,
      'isJoined': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    const primaryIndigo = Colors.indigo;
    final user = widget.authService.currentUser;
    final isSocietyMember = user?.isSocietyMember ?? false;

    final filteredSocieties = _societies.where((s) {
      if (_selectedCategory == 'All') return true;
      return s['category'] == _selectedCategory;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
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
                        isSocietyMember
                            ? 'Verified Society Member'
                            : 'Explore Campus Societies',
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
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
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
                    side: BorderSide(
                      color: isSelected ? primaryIndigo : Colors.indigo.shade100,
                    ),
                  ),
                  showCheckmark: false,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = cat);
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Societies List
          ...filteredSocieties.map((soc) {
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
                            soc['icon'] as IconData,
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
                                soc['name'] as String,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${soc['category']} • ${soc['members']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      soc['description'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryIndigo,
                            side: const BorderSide(color: primaryIndigo),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Viewing ${soc['name']} details...'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: primaryIndigo,
                              ),
                            );
                          },
                          child: const Text('View Society'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryIndigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Joined ${soc['name']}!'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: primaryIndigo,
                              ),
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
      ),
    );
  }
}
