import 'package:flutter/widgets.dart';
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

      // Restore session instantly from local storage
      final isLoggedIn = await authController.tryAutoLogin();

      await Future.delayed(const Duration(milliseconds: 400));

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isLoggedIn) {
          Get.offAllNamed(Routes.HOME);
        } else {
          Get.offAllNamed(Routes.LOGIN);
        }
      });
    } catch (_) {
      // Guaranteed safety fallback to Login Screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(Routes.LOGIN);
      });
    }
  }
}
