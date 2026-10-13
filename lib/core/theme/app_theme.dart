import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

/// AppTheme provides dual-theming ("Obsidian Dark" luxury & "Nordic Minimalist" light)
/// with dynamic typographic switching between Cairo (Arabic) and Plus Jakarta Sans (English).
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => getDarkTheme(isArabic: false);
  static ThemeData get nordicLightTheme => getNordicLightTheme(isArabic: false);

  /// Backwards-compatible getTheme helper
  static ThemeData getTheme({bool isArabic = false, bool isDark = true}) {
    return isDark
        ? getDarkTheme(isArabic: isArabic)
        : getNordicLightTheme(isArabic: isArabic);
  }

  /// 1. Obsidian Dark Luxury Theme
  static ThemeData getDarkTheme({bool isArabic = false}) {
    final textTheme =
        AppTypography.buildTextTheme(isArabic: isArabic, isDark: true);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      cardColor: AppColors.surfaceDarkCard,
      primaryColor: AppColors.neonCyan,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonCyan,
        secondary: AppColors.amberGold,
        surface: AppColors.surfaceDark,
        error: AppColors.passRed,
        onPrimary: AppColors.backgroundDark,
        onSecondary: AppColors.backgroundDark,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
        outlineVariant: AppColors.borderLight,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.neonCyan,
        unselectedItemColor: AppColors.textMuted,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: textTheme.headlineMedium,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDarkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.neonCyan,
        inactiveTrackColor: AppColors.surfaceDarkElevated,
        thumbColor: AppColors.neonCyan,
        overlayColor: AppColors.cyanGlow,
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonCyan,
          foregroundColor: AppColors.backgroundDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.borderLight, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        modalBackgroundColor: AppColors.surfaceDark,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 24,
      ),
      textTheme: textTheme,
    );
  }

  /// 2. Nordic Minimalist Light Theme
  /// Warm ivory/cream background (#FBF9F5), elevated white cards (#FFFFFF),
  /// Royal Deep Navy headings (#0F1B2B), Champagne Brushed Gold accents (#C5A880),
  /// and Sophisticated Forest Green (#2D5A46) for yield states.
  static ThemeData getNordicLightTheme({bool isArabic = false}) {
    final textTheme =
        AppTypography.buildTextTheme(isArabic: isArabic, isDark: false);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFBF9F5),
      cardColor: Colors.white,
      primaryColor: const Color(0xFFC5A880),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFC5A880), // Champagne Gold
        secondary: Color(0xFF2D5A46), // Forest Green
        surface: Colors.white,
        error: AppColors.passRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF0F1B2B), // Deep Navy
        onError: Colors.white,
        outlineVariant: Color(0xFFE5E2DC),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFFC5A880),
        unselectedItemColor: Color(0xFF0F1B2B),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: AppColors.nordicNavy),
        titleTextStyle: textTheme.headlineMedium?.copyWith(
          color: AppColors.nordicNavy,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.nordicSurface,
        elevation: 1,
        shadowColor: AppColors.nordicShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.nordicBorder, width: 1),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.champagneGold,
        inactiveTrackColor: AppColors.nordicBorder,
        thumbColor: AppColors.champagneGold,
        overlayColor: AppColors.champagneGoldGlow,
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.nordicNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.nordicNavy,
          side: const BorderSide(color: AppColors.nordicBorder, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.nordicSurface,
        modalBackgroundColor: AppColors.nordicSurface,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.nordicBorder,
        thickness: 1,
        space: 24,
      ),
      textTheme: textTheme,
    );
  }
}
