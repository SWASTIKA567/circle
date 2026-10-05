import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../controllers/events_controller.dart';
import '../../auth/controllers/auth_controller.dart';

class EventsView extends GetView<EventsController> {
  const EventsView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Get.find<AuthController>().currentUser.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        final filteredEvents = controller.filteredEvents;
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          children: [
            // Greeting Card - Sleek Dark Card #222222 matching reference style
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.1),
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
                        'Welcome, ${user != null && user.name.isNotEmpty ? user.name.split(' ')[0] : 'Student'}!',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.purpleLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user != null && user.studentNo.isNotEmpty ? user.studentNo : 'CAMPUS',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.card),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explore upcoming campus fests, hackathons, and society events happening around you.',
                    style: TextStyle(fontSize: 13, color: AppColors.white.withValues(alpha: 0.7), height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Header with Sandwich Bar Category Selector
            Row(
              children: [
                const Text(
                  'Upcoming Events',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.text),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.grayFade(0.15)),
                  ),
                  child: Text(
                    '${filteredEvents.length} Events',
                    style: const TextStyle(fontSize: 11, color: AppColors.gray, fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),

                // Sandwich Bar Button
                InkWell(
                  onTap: () => showCategoriesModal(context, controller),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: controller.selectedCategory.value == 'All'
                          ? AppColors.white
                          : AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: controller.selectedCategory.value == 'All'
                            ? AppColors.grayFade(0.2)
                            : AppColors.card,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.menu_rounded,
                          size: 16,
                          color: controller.selectedCategory.value == 'All'
                              ? AppColors.text
                              : AppColors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          controller.selectedCategory.value == 'All'
                              ? 'Categories'
                              : controller.selectedCategory.value,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: controller.selectedCategory.value == 'All'
                                ? AppColors.text
                                : AppColors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: controller.selectedCategory.value == 'All'
                              ? AppColors.gray
                              : AppColors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Active category filter tag (if not 'All')
            if (controller.selectedCategory.value != 'All') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.purpleLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.card),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Category: ${controller.selectedCategory.value}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.card),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => controller.selectCategory('All'),
                          child: const Icon(Icons.close_rounded, size: 16, color: AppColors.card),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),

            // Empty state or events
            if (filteredEvents.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.grayFade(0.12)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.event_busy_outlined, size: 52, color: AppColors.grayFade(0.5)),
                    const SizedBox(height: 12),
                    Text(
                      controller.selectedCategory.value == 'All'
                          ? 'No upcoming events'
                          : 'No events in "${controller.selectedCategory.value}"',
                      style: const TextStyle(color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Campus events and fests will appear here.',
                      style: TextStyle(color: AppColors.gray, fontSize: 13),
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
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.grayFade(0.12)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
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
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    dateParts[0],
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.white),
                                  ),
                                  Text(
                                    dateParts.length > 1 ? dateParts[1] : '',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.purple),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event['title'] as String,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'By ${event['society']}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.gray),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.schedule_rounded, size: 15, color: AppColors.gray),
                              const SizedBox(width: 6),
                              Text(event['time'] as String, style: const TextStyle(fontSize: 12, color: AppColors.text)),
                              const Spacer(),
                              const Icon(Icons.place_outlined, size: 15, color: AppColors.gray),
                              const SizedBox(width: 4),
                              Text(event['venue'] as String, style: const TextStyle(fontSize: 12, color: AppColors.text)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.blueLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                event['type'] as String,
                                style: const TextStyle(fontSize: 11, color: AppColors.card, fontWeight: FontWeight.w700),
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isRsvp ? AppColors.green : AppColors.card,
                                foregroundColor: isRsvp ? AppColors.black : AppColors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                  backgroundColor: isRsvp ? AppColors.card : AppColors.greenLight,
                                  colorText: isRsvp ? AppColors.white : AppColors.text,
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

  static void showCategoriesModal(BuildContext context, EventsController controller) {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grayFade(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.menu_rounded, color: AppColors.card, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Event Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  Obx(() => controller.selectedCategory.value != 'All'
                      ? TextButton(
                          onPressed: () {
                            controller.selectCategory('All');
                            Get.back();
                          },
                          child: const Text(
                            'Reset to All',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.card,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : const SizedBox.shrink()),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Select a category to filter upcoming campus events',
                style: TextStyle(fontSize: 12, color: AppColors.gray),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: controller.categories.map((cat) {
                      return Obx(() {
                        final isSelected = controller.selectedCategory.value == cat;
                        IconData iconData;
                        switch (cat) {
                          case 'Technical':
                            iconData = Icons.code_rounded;
                            break;
                          case 'Cultural':
                            iconData = Icons.theater_comedy_rounded;
                            break;
                          case 'Workshop':
                            iconData = Icons.handyman_rounded;
                            break;
                          case 'Literary':
                            iconData = Icons.auto_stories_rounded;
                            break;
                          default:
                            iconData = Icons.grid_view_rounded;
                        }

                        final count = cat == 'All'
                            ? controller.events.length
                            : controller.events.where((e) => e['type'] == cat).length;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.purpleLight : AppColors.background,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppColors.card : AppColors.grayFade(0.12),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                            leading: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.card : AppColors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                iconData,
                                color: isSelected ? AppColors.white : AppColors.gray,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              cat == 'All' ? 'All Categories' : cat,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? AppColors.card : AppColors.text,
                              ),
                            ),
                            subtitle: Text(
                              '$count event${count == 1 ? '' : 's'}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected ? AppColors.card.withValues(alpha: 0.8) : AppColors.gray,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle_rounded, color: AppColors.card, size: 22)
                                : const Icon(Icons.chevron_right_rounded, color: AppColors.gray, size: 20),
                            onTap: () {
                              controller.selectCategory(cat);
                              Get.back();
                            },
                          ),
                        );
                      });
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
