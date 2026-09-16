import 'package:flutter/material.dart';

class EventsTab extends StatefulWidget {
  const EventsTab({super.key});

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
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
        },
      ),
    );
  }
}
