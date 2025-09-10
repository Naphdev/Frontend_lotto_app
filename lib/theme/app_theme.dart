import 'package:flutter/material.dart';
import 'package:lotto_app/constants/app_constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.light,
        primary: AppConstants.primaryColor,
        secondary: AppConstants.secondaryColor,
        surface: AppConstants.surfaceColor,
        error: AppConstants.errorColor,
        onPrimary: Colors.white,
        onSecondary: AppConstants.textPrimary,
        onSurface: AppConstants.textPrimary,
        onError: Colors.white,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: AppConstants.fontSizeL,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppConstants.surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, AppConstants.buttonHeightM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          ),
          textStyle: const TextStyle(
            fontSize: AppConstants.fontSizeM,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppConstants.primaryColor,
          textStyle: const TextStyle(
            fontSize: AppConstants.fontSizeM,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.primaryColor,
          side: const BorderSide(color: AppConstants.primaryColor),
          minimumSize: const Size(double.infinity, AppConstants.buttonHeightM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          ),
          textStyle: const TextStyle(
            fontSize: AppConstants.fontSizeM,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          borderSide:
              const BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          borderSide:
              const BorderSide(color: AppConstants.errorColor, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          borderSide:
              const BorderSide(color: AppConstants.errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingL,
          vertical: AppConstants.spacingM,
        ),
        hintStyle: const TextStyle(
          color: AppConstants.textHint,
          fontSize: AppConstants.fontSizeM,
        ),
        labelStyle: const TextStyle(
          color: AppConstants.textSecondary,
          fontSize: AppConstants.fontSizeM,
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: AppConstants.fontSizeXXL,
          fontWeight: FontWeight.bold,
          color: AppConstants.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: AppConstants.fontSizeXL,
          fontWeight: FontWeight.bold,
          color: AppConstants.textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: AppConstants.fontSizeL,
          fontWeight: FontWeight.bold,
          color: AppConstants.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: AppConstants.fontSizeXL,
          fontWeight: FontWeight.w600,
          color: AppConstants.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: AppConstants.fontSizeL,
          fontWeight: FontWeight.w600,
          color: AppConstants.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: AppConstants.fontSizeM,
          fontWeight: FontWeight.w600,
          color: AppConstants.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: AppConstants.fontSizeL,
          fontWeight: FontWeight.w500,
          color: AppConstants.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: AppConstants.fontSizeM,
          fontWeight: FontWeight.w500,
          color: AppConstants.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: AppConstants.fontSizeS,
          fontWeight: FontWeight.w500,
          color: AppConstants.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: AppConstants.fontSizeM,
          color: AppConstants.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: AppConstants.fontSizeS,
          color: AppConstants.textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: AppConstants.fontSizeXS,
          color: AppConstants.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: AppConstants.fontSizeM,
          fontWeight: FontWeight.w500,
          color: AppConstants.textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: AppConstants.fontSizeS,
          fontWeight: FontWeight.w500,
          color: AppConstants.textPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: AppConstants.fontSizeXS,
          fontWeight: FontWeight.w500,
          color: AppConstants.textSecondary,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppConstants.surfaceColor,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: AppConstants.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppConstants.textPrimary,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: AppConstants.fontSizeM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppConstants.textHint,
        thickness: 1,
        space: 1,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppConstants.primaryColor,
        linearTrackColor: AppConstants.textHint,
        circularTrackColor: AppConstants.textHint,
      ),
    );
  }

  // Custom button styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, AppConstants.buttonHeightM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        ),
        textStyle: const TextStyle(
          fontSize: AppConstants.fontSizeM,
          fontWeight: FontWeight.w600,
        ),
      );

  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
        foregroundColor: AppConstants.primaryColor,
        side: const BorderSide(color: AppConstants.primaryColor),
        minimumSize: const Size(double.infinity, AppConstants.buttonHeightM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        ),
        textStyle: const TextStyle(
          fontSize: AppConstants.fontSizeM,
          fontWeight: FontWeight.w600,
        ),
      );

  static ButtonStyle get successButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: AppConstants.successColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, AppConstants.buttonHeightM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        ),
        textStyle: const TextStyle(
          fontSize: AppConstants.fontSizeM,
          fontWeight: FontWeight.w600,
        ),
      );

  static ButtonStyle get errorButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: AppConstants.errorColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, AppConstants.buttonHeightM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        ),
        textStyle: const TextStyle(
          fontSize: AppConstants.fontSizeM,
          fontWeight: FontWeight.w600,
        ),
      );
}
