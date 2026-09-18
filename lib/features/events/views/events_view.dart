import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/events_controller.dart';
import '../../auth/controllers/auth_controller.dart';

class EventsView extends GetView<EventsController> {
  const EventsView({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryIndigo = Colors.indigo;
    final user = Get.find<AuthController>().currentUser.value;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        final filteredEvents = controller.filteredEvents;
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          children: [
            // Greeting Card
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
                          user != null && user.studentNo.isNotEmpty ? user.studentNo : 'CAMPUS 2026',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Explore upcoming campus fests, hackathons, and society events happening around you.',
                    style: TextStyle(fontSize: 13, color: Colors.indigo.shade100, height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Category Filter
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

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Campus Events',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryIndigo),
                ),
                Text(
                  '${filteredEvents.length} Events',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Empty state or events
            if (filteredEvents.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.event_busy_outlined, size: 56, color: Colors.indigo.shade200),
                    const SizedBox(height: 12),
                    Text(
                      controller.selectedCategory.value == 'All'
                          ? 'No upcoming events'
                          : 'No events in "${controller.selectedCategory.value}"',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Campus events and fests will appear here.',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  ],
                ),
              )
            else
              ...filteredEvents.asMap().entries.map((entry) {
                final index = entry.key;
                final event = entry.value;
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: primaryIndigo,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(dateParts[0],
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                                  Text(dateParts[1],
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigo.shade100)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(event['title'] as String,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
                                  const SizedBox(height: 4),
                                  Text('By ${event['society']}',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.indigo.shade400)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.schedule_rounded, size: 16, color: Colors.indigo.shade400),
                              const SizedBox(width: 6),
                              Text(event['time'] as String, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                              const Spacer(),
                              Icon(Icons.place_outlined, size: 16, color: Colors.indigo.shade400),
                              const SizedBox(width: 4),
                              Text(event['venue'] as String, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
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
                                style: const TextStyle(fontSize: 11, color: primaryIndigo, fontWeight: FontWeight.w600),
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isRsvp ? Colors.green : primaryIndigo,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                              icon: Icon(isRsvp ? Icons.check_rounded : Icons.bookmark_add_outlined, size: 16),
                              label: Text(
                                isRsvp ? 'Registered' : 'Register / RSVP',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                controller.rsvpEvent(index);
                                Get.snackbar(
                                  isRsvp ? 'Cancelled' : 'Registered!',
                                  isRsvp
                                      ? 'Cancelled registration for ${event['title']}.'
                                      : 'Successfully registered for ${event['title']}!',
                                  backgroundColor: isRsvp ? Colors.indigo.shade50 : Colors.green.shade50,
                                  colorText: isRsvp ? Colors.indigo.shade900 : Colors.green.shade900,
                                  snackPosition: SnackPosition.BOTTOM,
                                  margin: const EdgeInsets.all(16),
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
        );
      }),
    );
  }
}
