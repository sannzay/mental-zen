import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF4A90A4);
  static const Color secondary = Color(0xFF7CB9A8);
  static const Color accent = Color(0xFFF5E6D3);
  static const Color background = Color(0xFFF8FAFB);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color error = Color(0xFFE74C3C);
}

ThemeData buildLightTheme() {
  final base = ThemeData.light();
  final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme).apply(
    bodyColor: AppColors.textPrimary,
    displayColor: AppColors.textPrimary,
  );
  return base.copyWith(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      background: AppColors.background,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      centerTitle: true,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}


