import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/bindings/auth_binding.dart';
import '../controllers/home_controller.dart';
import '../../events/controllers/events_controller.dart';
import '../../notes/controllers/notes_controller.dart';
import '../../societies/controllers/societies_controller.dart';
import '../../chatbot/controllers/chatbot_controller.dart';

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
