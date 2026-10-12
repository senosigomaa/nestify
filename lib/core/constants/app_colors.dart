import 'package:flutter/material.dart';

/// AppColors defines the signature dark luxury aesthetic palette for Nestify:
/// Deep matte obsidian/slate background with neon cyan and amber gold accents.
class AppColors {
  AppColors._();

  // Background & Surface
  static const Color backgroundDark = Color(0xFF0A0E17);
  static const Color surfaceDark = Color(0xFF141C2B);
  static const Color surfaceDarkElevated = Color(0xFF1E293B);
  static const Color surfaceDarkCard = Color(0xFF162032);
  static const Color surfaceGlass = Color(0xCC141C2B);

  // Accents & Brand
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color cyanVariant = Color(0xFF00B4D8);
  static const Color cyanGlow = Color(0x3300E5FF);
  static const Color amberGold = Color(0xFFFFB300);
  static const Color amberGlow = Color(0x33FFB300);
  static const Color sunsetOrange = Color(0xFFFF5722);

  // Status & Actions
  static const Color passRed = Color(0xFFFF3366);
  static const Color passRedGlow = Color(0x33FF3366);
  static const Color likeGreen = Color(0xFF00E676);
  static const Color likeGreenGlow = Color(0x3300E676);

  // Text
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Borders & Dividers
  static const Color borderLight = Color(0x1AFFFFFF);
  static const Color borderCyan = Color(0x3300E5FF);
  static const Color borderAmber = Color(0x33FFB300);

  // Gradients
  static const LinearGradient cyanGradient = LinearGradient(
    colors: [neonCyan, cyanVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: [amberGold, sunsetOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardOverlay = LinearGradient(
    colors: [
      Colors.transparent,
      Color(0x990A0E17),
      Color(0xF00A0E17),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x33FFFFFF),
      Color(0x0DFFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
