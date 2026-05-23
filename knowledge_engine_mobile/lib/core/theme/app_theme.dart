import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Application theme configuration
class AppTheme {
  // Color palette
  // Dark backgrounds
  static const Color darkBg = Color(0xFF0D0F14);
  static const Color darkSurface = Color(0xFF161923);
  static const Color darkCard = Color(0xFF1E2230);
  static const Color darkCardHov = Color(0xFF252A3A);

  // Dark text
  static const Color darkTextPrimary = Color(0xFFF0F2FF);
  static const Color darkTextSecondary = Color(0xFF8891B0);
  static const Color darkTextTertiary = Color(0xFF555E7A);

  // Light backgrounds
  static const Color lightBg = Color(0xFFF5F6FA);
  static const Color lightSurface = Color(0xFFEDEEF4);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardHov = Color(0xFFF0F1F7);

  // Light text
  static const Color lightTextPrimary = Color(0xFF111318);
  static const Color lightTextSecondary = Color(0xFF4A5068);
  static const Color lightTextTertiary = Color(0xFF8891A8);

  // Feature accents (ثابتة في الثيمين)
  static const Color teal = Color(0xFF38EFC4); // Documents
  static const Color indigo = Color(0xFF6C8EFF); // Ask AI
  static const Color purple = Color(0xFFB07CFF); // Voice
  static const Color amber = Color(0xFFFFB547); // Translate

  // Semantic
  static const Color successDark = Color(0xFF38EFC4);
  static const Color successLight = Color(0xFF1D9E75);
  static const Color errorDark = Color(0xFFFF5C6B);
  static const Color errorLight = Color(0xFFD83A3A);
  static const Color warningDark = Color(0xFFFFB547);
  static const Color warningLight = Color(0xFFBA7517);
  static const Color infoDark = Color(0xFF6C8EFF);
  static const Color infoLight = Color(0xFF3D5AF1);

  // Derived / legacy names
  static const Color primaryColor = indigo;
  static const Color secondaryColor = teal;
  static const Color tertiaryColor = amber;
  static const Color voiceColor = purple;
  static const Color accentColor = teal;

  // Legacy / compatibility aliases (keep old variable names)
  static const Color backgroundColor = lightBg;
  static const Color surfaceColor = lightSurface;
  static const Color successColor = successLight;
  static const Color errorColor = errorLight;
  static const Color warningColor = warningLight;
  static const Color infoColor = infoLight;

  static const Color borderColor = Color(0xFFE0E0E0);

  // Text aliases used by existing widgets (default to light)
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textHint = Color(0xFFBDBDBD);

  /// Light theme
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Poppins',
      fontFamilyFallback: const ['Roboto', 'Arial'],
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        surface: surfaceColor,
        error: errorColor,
        brightness: Brightness.light,
      ),
      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      // Text themes
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28.sp,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        labelMedium: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          textStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          side: const BorderSide(color: primaryColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          textStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          textStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        hintStyle: const TextStyle(color: textHint),
        labelStyle: const TextStyle(color: textSecondary),
        errorStyle: const TextStyle(color: errorColor),
      ),
      // Cards
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
        margin: EdgeInsets.all(0.r),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
      // Dividers
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 16,
      ),
      // Snack bar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: TextStyle(
          fontSize: 14.sp,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
      // Progress indicators
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
      ),
      // Checkbox and Radio
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.white;
        }),
        side: const BorderSide(color: borderColor),
      ),
    );
  }

  /// Dark theme
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Poppins',
      fontFamilyFallback: const ['Roboto', 'Arial'],
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBg,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: voiceColor,
        surface: darkSurface,
        background: darkBg,
        error: errorDark,
        brightness: Brightness.dark,
      ),
      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
      ),
      // Text themes
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28.sp,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: darkTextPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: darkTextSecondary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.normal,
          color: darkTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.normal,
          color: darkTextPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.normal,
          color: darkTextSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
      ),
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: darkTextPrimary,
          elevation: 2,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          textStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          side: BorderSide(color: primaryColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          textStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          textStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: darkCardHov),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: darkCardHov),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: errorDark),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: errorDark, width: 2),
        ),
        hintStyle: TextStyle(color: darkTextTertiary),
        labelStyle: TextStyle(color: darkTextSecondary),
        errorStyle: TextStyle(color: errorDark),
      ),
      // Cards
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 2,
        margin: EdgeInsets.all(0.r),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
      // Dividers
      dividerTheme: DividerThemeData(
        color: darkCardHov,
        thickness: 1,
        space: 16,
      ),
      // Snack bar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurface,
        contentTextStyle: TextStyle(
          fontSize: 14.sp,
          color: darkTextPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
      // Progress indicators
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
      ),
      // Checkbox and Radio
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return darkCard;
        }),
        side: BorderSide(color: darkCardHov),
      ),
    );
  }

  /// Get feature-specific color
  static Color getFeatureColor(String feature) {
    switch (feature) {
      case 'files':
        return secondaryColor;
      case 'ask':
        return primaryColor;
      case 'translate':
        return tertiaryColor;
      case 'search':
        return accentColor;
      default:
        return primaryColor;
    }
  }

  /// Get status color
  static Color getStatusColor(String status) {
    switch (status) {
      case 'success':
      case 'completed':
        return successColor;
      case 'error':
      case 'failed':
        return errorColor;
      case 'warning':
        return warningColor;
      case 'pending':
      case 'processing':
        return infoColor;
      default:
        return infoColor;
    }
  }

  /// Get score color based on confidence
  static Color getScoreColor(double score) {
    if (score >= 0.9) {
      return successColor;
    } else if (score >= 0.7) {
      return warningColor;
    } else {
      return errorColor;
    }
  }
}
