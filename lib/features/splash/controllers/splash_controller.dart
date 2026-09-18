import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../features/auth/bindings/auth_binding.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      // Initialize AuthController early if not yet registered
      if (!Get.isRegistered<AuthController>()) {
        AuthBinding().dependencies();
      }

      final authController = Get.find<AuthController>();

      // Safe timeout for auto-login so splash NEVER hangs
      final isLoggedIn = await authController
          .tryAutoLogin()
          .timeout(const Duration(seconds: 3), onTimeout: () => false);

      await Future.delayed(const Duration(milliseconds: 500));

      if (isLoggedIn) {
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.offAllNamed(Routes.LOGIN);
      }
    } catch (_) {
      // Guaranteed safety fallback to Login Screen
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
