// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
    );
  }
}
