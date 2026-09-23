import 'package:get/get.dart';
import 'app_routes.dart';
import '../../features/splash/bindings/splash_binding.dart';
import '../../features/splash/views/splash_view.dart';
import '../../features/auth/bindings/auth_binding.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/register_view.dart';
import '../../features/home/bindings/home_binding.dart';
import '../../features/home/views/home_view.dart';
import '../../features/admin/views/admin_view.dart';

// ignore_for_file: constant_identifier_names

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.ADMIN,
      page: () => const AdminView(),
    ),
  ];
}
