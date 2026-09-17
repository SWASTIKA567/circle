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
    // Put AuthController early so it can be used throughout the app
    if (!Get.isRegistered<AuthController>()) {
      AuthBinding().dependencies();
    }
    final authController = Get.find<AuthController>();
    final isLoggedIn = await authController.tryAutoLogin();

    await Future.delayed(const Duration(milliseconds: 800));

    if (isLoggedIn) {
      Get.offAllNamed(Routes.HOME);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
