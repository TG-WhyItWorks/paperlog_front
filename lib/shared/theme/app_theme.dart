import 'package:flutter/material.dart';
import 'color_schemes.dart';
import 'text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: AppColors.lightPrimary,
      colorScheme: ColorScheme.light(
        primary: AppColors.lightPrimary, // KyungHee Red
        onPrimary: AppColors.lightOnPrimary,
        secondary: AppColors.khBlue, // KyungHee Blue
        onSecondary: Colors.white,
        tertiary: AppColors.khGold, // KyungHee Gold
        surface: AppColors.lightSurface,
        background: AppColors.lightBackground,
        onSurface: AppColors.lightText,
      ),
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.headline1,
        displayMedium: AppTextStyles.headline2,
        bodyLarge: AppTextStyles.body1,
        bodySmall: AppTextStyles.caption,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightPrimary,
        titleTextStyle: TextStyle(
          color: AppColors.lightOnPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: AppColors.lightOnPrimary),
      ),
      dividerColor: AppColors.khSilver,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      primaryColor: AppColors.darkPrimary,
      colorScheme: ColorScheme.dark(
        primary: AppColors.darkPrimary, // KyungHee Red
        onPrimary: AppColors.darkOnPrimary,
        secondary: AppColors.khGold, // Gold 포인트
        onSecondary: Colors.black,
        tertiary: AppColors.khBlue, // Blue 서브 톤
        surface: AppColors.darkSurface,
        background: AppColors.darkBackground,
        onSurface: AppColors.darkText,
      ),
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.headline1,
        displayMedium: AppTextStyles.headline2,
        bodyLarge: AppTextStyles.body1,
        bodySmall: AppTextStyles.caption,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkPrimary,
        titleTextStyle: TextStyle(
          color: AppColors.darkOnPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: AppColors.darkOnPrimary),
      ),
      dividerColor: AppColors.khCoolGray,
    );
  }
}
