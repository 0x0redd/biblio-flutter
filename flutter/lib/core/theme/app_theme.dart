import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle headlineLarge(Color color) => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: color,
      );

  static TextStyle headlineMedium(Color color) => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle bodyLarge(Color color) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: color,
      );

  static TextStyle bodyMedium(Color color) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: color,
      );

  static TextStyle label(Color color) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
      );
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.onPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.headlineLarge(AppColors.text),
        headlineMedium: AppTextStyles.headlineMedium(AppColors.text),
        bodyLarge: AppTextStyles.bodyLarge(AppColors.text),
        bodyMedium: AppTextStyles.bodyMedium(AppColors.text),
        labelMedium: AppTextStyles.label(AppColors.textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.text,
        elevation: 0,
        titleTextStyle: AppTextStyles.headlineMedium(AppColors.text),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.headlineLarge(AppColors.textDark),
        headlineMedium: AppTextStyles.headlineMedium(AppColors.textDark),
        bodyLarge: AppTextStyles.bodyLarge(AppColors.textDark),
        bodyMedium: AppTextStyles.bodyMedium(AppColors.textDark),
        labelMedium: AppTextStyles.label(AppColors.textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        titleTextStyle: AppTextStyles.headlineMedium(AppColors.textDark),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.3)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
