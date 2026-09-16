import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class EventsTab extends StatefulWidget {
  final AuthService? authService;

  const EventsTab({super.key, this.authService});

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Technical',
    'Cultural',
    'Workshop',
    'Literary',
  ];

  final List<Map<String, dynamic>> _events = [
    {
      'title': 'HackCircle 2026: 24h Hackathon',
      'society': 'Google Developer Student Club',
      'date': '28 SEP',
      'time': '10:00 AM - Next Day',
      'venue': 'Auditorium Hall B',
      'type': 'Technical',
      'isRsvp': false,
    },
    {
      'title': 'AI & Robotics Workshop: Hands-on IoT',
      'society': 'Robotics & Automation Society',
      'date': '04 OCT',
      'time': '02:00 PM - 05:00 PM',
      'venue': 'Hardware Lab 3',
      'type': 'Workshop',
      'isRsvp': false,
    },
    {
      'title': 'Symphony 2026: Annual Music Night',
      'society': 'Cadence Music Society',
      'date': '12 OCT',
      'time': '06:00 PM - 09:30 PM',
      'venue': 'Open Air Theatre (OAT)',
      'type': 'Cultural',
      'isRsvp': false,
    },
    {
      'title': 'National Youth Parliamentary Debate',
      'society': 'Orators Debating Society',
      'date': '19 OCT',
      'time': '11:00 AM - 04:00 PM',
      'venue': 'Seminar Hall 1',
      'type': 'Literary',
      'isRsvp': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    const primaryIndigo = Colors.indigo;
    final user = widget.authService?.currentUser;

    final filteredEvents = _events.where((e) {
      if (_selectedCategory == 'All') return true;
      return e['type'] == _selectedCategory;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        children: [
          // Home Greeting Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade700, Colors.indigo.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryIndigo.withValues(alpha: 0.25),
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
                    Text(
                      'Welcome back, ${user != null && user.name.isNotEmpty ? user.name.split(' ')[0] : 'Student'}!',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user != null && user.studentNo.isNotEmpty
                            ? user.studentNo
                            : 'CAMPUS 2026',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Explore upcoming campus fests, hackathons, and society events happening around you.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.indigo.shade100,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Categories Filter Row
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

          // Events Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upcoming Campus Events',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryIndigo,
                ),
              ),
              Text(
                '${filteredEvents.length} Events',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Events List
          ...filteredEvents.map((event) {
            final isRsvp = event['isRsvp'] as bool;
            final dateParts = (event['date'] as String).split(' ');

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.indigo.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withValues(alpha: 0.04),
                    blurRadius: 12,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Box
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: primaryIndigo,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: primaryIndigo.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                dateParts[0],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                dateParts[1],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo.shade100,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Event Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['title'] as String,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'By ${event['society']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: primaryIndigo.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Metadata Info (Time & Venue)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.schedule_rounded, size: 16, color: primaryIndigo.shade400),
                          const SizedBox(width: 6),
                          Text(
                            event['time'] as String,
                            style: const TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                          const Spacer(),
                          Icon(Icons.place_outlined, size: 16, color: primaryIndigo.shade400),
                          const SizedBox(width: 4),
                          Text(
                            event['venue'] as String,
                            style: const TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            event['type'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              color: primaryIndigo,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isRsvp ? Colors.green : primaryIndigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          icon: Icon(
                            isRsvp ? Icons.check_rounded : Icons.bookmark_add_outlined,
                            size: 16,
                          ),
                          label: Text(
                            isRsvp ? 'Registered' : 'Register / RSVP',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            setState(() {
                              event['isRsvp'] = !isRsvp;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  !isRsvp
                                      ? 'Successfully registered for ${event['title']}!'
                                      : 'Cancelled registration for ${event['title']}.',
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: !isRsvp ? Colors.green.shade700 : primaryIndigo,
                              ),
                            );
                          },
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
