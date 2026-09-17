import 'package:get/get.dart';

class EventsController extends GetxController {
  final RxString selectedCategory = 'All'.obs;
  final RxList<Map<String, dynamic>> events = <Map<String, dynamic>>[].obs;

  final List<String> categories = ['All', 'Technical', 'Cultural', 'Workshop', 'Literary'];

  List<Map<String, dynamic>> get filteredEvents {
    if (selectedCategory.value == 'All') return events;
    return events.where((e) => e['type'] == selectedCategory.value).toList();
  }

  void selectCategory(String category) => selectedCategory.value = category;

  void rsvpEvent(int index) {
    // Find actual index in events list
    final event = filteredEvents[index];
    final realIndex = events.indexOf(event);
    if (realIndex != -1) {
      events[realIndex] = {...event, 'isRsvp': !(event['isRsvp'] as bool)};
    }
  }
}
