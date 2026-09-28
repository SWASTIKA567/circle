import 'package:flutter/material.dart';

class AppColors {
  // ── Core Palette ──────────────────────────────────────────
  static const Color background = Color(0xFFF8F8F8);
  static const Color card       = Color(0xFF222222);
  static const Color black      = Color(0xFF171717);

  static const Color purple     = Color(0xFFC39AF0);
  static const Color pink       = Color(0xFFF0A5B8);
  static const Color green      = Color(0xFF83E94F);
  static const Color blue       = Color(0xFFB8C8F0);

  static const Color magenta    = Color(0xFFC95AA5);
  static const Color white      = Color(0xFFFFFFFF);
  static const Color text       = Color(0xFF151515);
  static const Color gray       = Color(0xFF777777);

  // ── Derived helpers ───────────────────────────────────────
  static const Color purpleLight  = Color(0xFFF0E8FD); // purple @ ~10% opacity bg
  static const Color pinkLight    = Color(0xFFFDE8EE);
  static const Color greenLight   = Color(0xFFEBFCDE);
  static const Color blueLight    = Color(0xFFE8EEF9);

  static Color purpleFade(double opacity) => purple.withValues(alpha: opacity);
  static Color pinkFade(double opacity)   => pink.withValues(alpha: opacity);
  static Color greenFade(double opacity)  => green.withValues(alpha: opacity);
  static Color blueFade(double opacity)   => blue.withValues(alpha: opacity);
  static Color grayFade(double opacity)   => gray.withValues(alpha: opacity);
  static Color textFade(double opacity)   => text.withValues(alpha: opacity);
}

class AppTheme {
  static const Color primary = AppColors.purple;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.purple,
        onPrimary: AppColors.text,
        secondary: AppColors.blue,
        onSecondary: AppColors.text,
        error: AppColors.pink,
        onError: AppColors.white,
        surface: AppColors.background,
        onSurface: AppColors.text,
        surfaceContainerHighest: AppColors.white,
        outline: AppColors.grayFade(0.25),
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.purpleLight,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.text),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.purple,
        foregroundColor: AppColors.text,
        elevation: 2,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.purple,
          foregroundColor: AppColors.text,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.purple,
          side: const BorderSide(color: AppColors.purple),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.purpleLight,
        selectedColor: AppColors.purple,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text),
        side: BorderSide(color: AppColors.grayFade(0.15)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.purpleLight.withValues(alpha: 0.5),
        labelStyle: const TextStyle(color: AppColors.gray),
        hintStyle: TextStyle(color: AppColors.grayFade(0.5)),
        prefixIconColor: AppColors.purple,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.grayFade(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.grayFade(0.2)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: AppColors.purple, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.pink, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.magenta, width: 2),
        ),
      ),
    );
  }
}
