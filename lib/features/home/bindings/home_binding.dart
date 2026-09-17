import 'package:get/get.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/auth/bindings/auth_binding.dart';
import '../features/home/controllers/home_controller.dart';
import '../features/events/controllers/events_controller.dart';
import '../features/notes/controllers/notes_controller.dart';
import '../features/societies/controllers/societies_controller.dart';
import '../features/chatbot/controllers/chatbot_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure AuthController is available (may already be registered from splash)
    if (!Get.isRegistered<AuthController>()) {
      AuthBinding().dependencies();
    }
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<EventsController>(() => EventsController());
    Get.lazyPut<NotesController>(() => NotesController());
    Get.lazyPut<SocietiesController>(() => SocietiesController());
    Get.lazyPut<ChatbotController>(() => ChatbotController());
  }
}
