import 'package:get/get.dart';
import '../features/auth/controllers/auth_controller.dart';

class HomeController extends GetxController {
  final RxInt currentIndex = 0.obs;

  late final AuthController authController;

  @override
  void onInit() {
    super.onInit();
    authController = Get.find<AuthController>();
  }

  String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return 'C';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  final List<String> tabTitles = [
    'Home & Events',
    'College Notes',
    'Circle AI Assistant',
    'Campus Societies',
  ];
}
