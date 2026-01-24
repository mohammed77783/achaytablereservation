import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dark theme configuration based on Navy + Mint design system
/// Lightened Navy backgrounds with vibrant Mint accents for dark mode
class DarkTheme {
  // Primary Navy - Lightened for dark mode visibility
  static const Color primaryColor = Color(0xFF2A3442); // primaryLight from light theme
  static const Color primaryLight = Color(0xFF3A4756);
  static const Color primaryDark = Color(0xFF1A2332); // original primary
  
  // Mint Accent - Brightened for dark mode contrast
  static const Color secondaryColor = Color(0xFF9DDDD0); // secondaryLight from light theme
  static const Color secondaryLight = Color(0xFFB3E8DE);
  static const Color secondaryDark = Color(0xFF7DD3C0); // original secondary
  
  // Accent Color (mint variant)
  static const Color accentColor = Color(0xFF9DDDD0);
  static const Color accentLight = Color(0xFFB3E8DE);
  
  // Background Colors - Dark navy-tinted backgrounds
  static const Color backgroundColor = Color(0xFF0F1419); // primaryDark from light
  static const Color surfaceColor = Color(0xFF1A2332); // primary from light
  static const Color cardBackground = Color(0xFF212C3D); // Slightly lighter than surface
  static const Color surfaceGray = Color(0xFF2A3442);
  
  // Text Colors - Light for dark backgrounds
  static const Color textPrimary = Color(0xFFE8EAED); // Light gray-white
  static const Color textSecondary = Color(0xFF9AA0A6); // Medium gray
  static const Color textHint = Color(0xFF5F6368); // Darker hint
  static const Color textOnPrimary = Color(0xFFE8EAED);
  static const Color textOnSecondary = Color(0xFF1A2332); // Dark navy for mint backgrounds
  
  // Status Colors - Brightened for dark mode
  static const Color successColor = Color(0xFF34D399); // Brighter green
  static const Color errorColor = Color(0xFFF87171); // Brighter red
  static const Color warningColor = Color(0xFFFBBF24); // Brighter yellow
  static const Color infoColor = Color(0xFF60A5FA); // Brighter blue
  
  // Border & Divider - Subtle dark variants
  static const Color borderColor = Color(0xFF3A4756);
  static const Color dividerColor = Color(0xFF2A3442);
  static const Color inputBorder = Color(0xFF3A4756);
  static const Color inputFocusBorder = Color(0xFF9DDDD0); // Mint for focus
  
  // Shadow - Darker for dark mode
  static const Color shadowColor = Color(0x40000000);
  static const Color shadowLight = Color(0x26000000);
  
  // Spacing Constants
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  
  // Sizing Constants
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double buttonHeight = 48.0;
  static const double borderRadius = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusXLarge = 16.0;

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        onPrimary: textOnPrimary,
        primaryContainer: primaryLight,
        secondary: secondaryColor,
        onSecondary: textOnSecondary,
        secondaryContainer: secondaryLight,
        tertiary: accentColor,
        tertiaryContainer: accentLight,
        surface: surfaceColor,
        onSurface: textPrimary,
        error: errorColor,
        onError: textOnPrimary,
      ),

      // Scaffold
      scaffoldBackgroundColor: backgroundColor,

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary, size: iconSizeMedium),
      ),

      // Card
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 0,
        shadowColor: shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
          side: const BorderSide(color: borderColor, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Text Theme
      textTheme: GoogleFonts.cairoTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          headlineLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: textPrimary,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: textSecondary,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          ),
          labelSmall: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: textHint,
          ),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryColor, // Mint accent for visibility in dark mode
          foregroundColor: textOnSecondary,
          minimumSize: const Size(double.infinity, buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: secondaryColor,
          minimumSize: const Size(double.infinity, buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          side: const BorderSide(color: secondaryColor, width: 1.5),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondaryColor,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: inputFocusBorder, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        hintStyle: const TextStyle(color: textHint, fontSize: 14),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: surfaceGray,
        selectedColor: secondaryColor,
        disabledColor: borderColor,
        labelStyle: const TextStyle(
          fontSize: 14,
          color: textPrimary,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 14,
          color: textOnSecondary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: const BorderSide(color: borderColor),
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: borderColor,
        dragHandleSize: Size(40, 4),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusXLarge),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 0,
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return secondaryColor;
          }
          return surfaceColor;
        }),
        checkColor: WidgetStateProperty.all(textOnSecondary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: const BorderSide(color: borderColor, width: 1.5),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: secondaryColor,
        linearTrackColor: borderColor,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: secondaryColor,
        foregroundColor: textOnSecondary,
        elevation: 4,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: iconSizeMedium,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: secondaryColor,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}