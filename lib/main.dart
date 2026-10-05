import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put<AuthController>(AuthController(), permanent: true);
  runApp(const CircleApp());
}

class CircleApp extends StatelessWidget {
  const CircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Circle',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: Routes.SPLASH,
      getPages: AppPages.routes,
    );
  }
}
