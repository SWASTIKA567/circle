import 'package:get/get.dart';
import '../../societies/controllers/societies_controller.dart';

class EventsController extends GetxController {
  final RxString selectedCategory = 'All'.obs;
  final RxString selectedTab = 'Upcoming'.obs; // 'Upcoming' or 'Past'
  final RxList<Map<String, dynamic>> events = <Map<String, dynamic>>[].obs;

  final List<String> categories = ['All', 'Technical', 'Cultural', 'Workshop', 'Literary'];

  /// All upcoming events: hardcoded static events + live society events within 2-day window
  List<Map<String, dynamic>> get allUpcomingEvents {
    final List<Map<String, dynamic>> combined = List.from(events);
    if (Get.isRegistered<SocietiesController>()) {
      final societiesCtrl = Get.find<SocietiesController>();
      final liveEvents = societiesCtrl.societyEventsForHomeFeed;
      for (final live in liveEvents) {
        final alreadyExists = combined.any(
          (e) => e['title'] == live['title'] && e['society'] == live['society'],
        );
        if (!alreadyExists) combined.add(live);
      }
    }
    return combined;
  }

  /// All past events from societies (after 2 days or explicit past)
  List<Map<String, dynamic>> get allPastEvents {
    final List<Map<String, dynamic>> past = [];
    if (Get.isRegistered<SocietiesController>()) {
      final societiesCtrl = Get.find<SocietiesController>();
      past.addAll(societiesCtrl.societyPastEventsForHomeFeed);
    }
    return past;
  }

  /// Current list of events depending on selected tab ('Upcoming' or 'Past')
  List<Map<String, dynamic>> get currentEventsList {
    return selectedTab.value == 'Upcoming' ? allUpcomingEvents : allPastEvents;
  }

  /// Filtered by category
  List<Map<String, dynamic>> get filteredEvents {
    final current = currentEventsList;
    if (selectedCategory.value == 'All') return current;
    return current.where((e) => e['type'] == selectedCategory.value).toList();
  }

  int get upcomingCount => allUpcomingEvents.length;
  int get pastCount => allPastEvents.length;

  void selectCategory(String category) => selectedCategory.value = category;
  void selectTab(String tab) => selectedTab.value = tab;

  void rsvpEvent(int index) {
    final event = filteredEvents[index];
    final source = event['source'];
    if (source == 'society') {
      return;
    }
    final realIndex = events.indexOf(event);
    if (realIndex != -1) {
      events[realIndex] = {...event, 'isRsvp': !(event['isRsvp'] as bool)};
    }
  }
}
