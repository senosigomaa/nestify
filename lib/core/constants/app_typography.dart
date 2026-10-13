import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// AppTypography provides the core typography scale for Nestify,
/// utilizing Plus Jakarta Sans for English and Cairo for Arabic.
class AppTypography {
  AppTypography._();

  // Headings
  static TextStyle displayLarge = GoogleFonts.plusJakartaSans(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.8,
  );

  static TextStyle displayMedium = GoogleFonts.plusJakartaSans(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle headlineLarge = GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle headlineMedium = GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body
  static TextStyle bodyLarge = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle bodySmall = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.3,
  );

  // Labels & Chips
  static TextStyle labelLarge = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );

  static TextStyle labelMedium = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
  );

  static TextStyle labelSmall = GoogleFonts.plusJakartaSans(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: AppColors.textMuted,
  );

  // Numeric & Metrics (Space Grotesk)
  static TextStyle priceTag = GoogleFonts.spaceGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.neonCyan,
    letterSpacing: -0.5,
  );

  static TextStyle metricValue = GoogleFonts.spaceGrotesk(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle badgeScore = GoogleFonts.spaceGrotesk(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.neonCyan,
    letterSpacing: 0.2,
  );

  /// Builds a full TextTheme customized for English (Plus Jakarta Sans) or Arabic (Cairo)
  /// and supports Obsidian Dark (isDark = true) or Nordic Minimalist (isDark = false, Deep Navy).
  static TextTheme buildTextTheme({bool isArabic = false, bool isDark = true}) {
    final primaryTextColor = isDark ? AppColors.textPrimary : AppColors.nordicNavy;
    final secondaryTextColor =
        isDark ? AppColors.textSecondary : AppColors.nordicNavySecondary;
    final mutedTextColor =
        isDark ? AppColors.textMuted : AppColors.nordicNavyMuted;

    if (isArabic) {
      return TextTheme(
        displayLarge: GoogleFonts.cairo(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: primaryTextColor,
        ),
        displayMedium: GoogleFonts.cairo(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: primaryTextColor,
        ),
        headlineLarge: GoogleFonts.cairo(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: primaryTextColor,
        ),
        headlineMedium: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: primaryTextColor,
        ),
        bodyLarge: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: primaryTextColor,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: secondaryTextColor,
          height: 1.4,
        ),
        bodySmall: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: mutedTextColor,
          height: 1.3,
        ),
        labelLarge: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: primaryTextColor,
        ),
        labelMedium: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: secondaryTextColor,
        ),
        labelSmall: GoogleFonts.cairo(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: mutedTextColor,
        ),
      );
    }

    if (!isDark) {
      return TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: primaryTextColor,
          letterSpacing: -0.8,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: primaryTextColor,
          letterSpacing: -0.5,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: primaryTextColor,
          letterSpacing: -0.3,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: primaryTextColor,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: primaryTextColor,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: secondaryTextColor,
          height: 1.4,
        ),
        bodySmall: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: mutedTextColor,
          height: 1.3,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primaryTextColor,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: secondaryTextColor,
          letterSpacing: 0.2,
        ),
        labelSmall: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: mutedTextColor,
        ),
      );
    }

    return TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    );
  }
}
