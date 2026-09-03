import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

class AppTheme {
  AppTheme._(); 

  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: AppFonts.fontFamily,
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryColor,
        secondary: AppColors.secondaryColor,
        error: AppColors.errorColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryColor,
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.fontFamily,
          fontSize: AppFonts.fontSizeLarge,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: AppFonts.regular,
        bodyMedium: AppFonts.regular,
        titleLarge: AppFonts.bold,
        titleMedium: AppFonts.semiBold,
      ),
    );
  }
}
