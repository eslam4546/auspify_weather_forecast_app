import 'package:flutter/material.dart';

/// Design tokens directly extracted from Google Stitch:
/// Project: "Flutter Weather Forecast App"
/// Design System: "Aether Atmospheric Weather"
class AppColors {
  // Dark Theme Tokens
  static const Color darkBackground = Color(0xFF0B1326);
  static const Color darkSurface = Color(0xFF0B1326);
  static const Color darkSurfaceContainerLowest = Color(0xFF060E20);
  static const Color darkSurfaceContainerLow = Color(0xFF131B2E);
  static const Color darkSurfaceContainer = Color(0xFF171F33);
  static const Color darkSurfaceContainerHigh = Color(0xFF222A3D);
  static const Color darkSurfaceContainerHighest = Color(0xFF2D3449);
  static const Color darkSurfaceBright = Color(0xFF31394D);

  static const Color darkOnSurface = Color(0xFFDAE2FD);
  static const Color darkOnSurfaceVariant = Color(0xFFBDC8D1);
  static const Color darkOutline = Color(0xFF87929A);
  static const Color darkOutlineVariant = Color(0xFF3E484F);

  // Light Theme Tokens
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFF8FAFC);
  static const Color lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLow = Color(0xFFF1F5F9);
  static const Color lightSurfaceContainer = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerHigh = Color(0xFFEFF6FF);
  static const Color lightSurfaceContainerHighest = Color(0xFFE2E8F0);

  static const Color lightOnSurface = Color(0xFF0F172A);
  static const Color lightOnSurfaceVariant = Color(0xFF64748B);
  static const Color lightOutline = Color(0xFF94A3B8);
  static const Color lightOutlineVariant = Color(0xFFCBD5E1);

  // Common Atmospheric Brand Accents
  static const Color primarySkyBlue = Color(0xFF38BDF8);
  static const Color primaryLight = Color(0xFF8ED5FF);
  static const Color onPrimaryDark = Color(0xFF00354A);
  static const Color onPrimaryContainerDark = Color(0xFF004965);

  static const Color secondaryWarmGold = Color(0xFFFFB95F);
  static const Color secondarySolarAmber = Color(0xFFF59E0B);
  static const Color secondaryContainer = Color(0xFFEE9800);

  static const Color tertiaryStratosphereBlue = Color(0xFF5CB9FF);
  static const Color tertiarySoftBlue = Color(0xFFA1D2FF);

  static const Color errorRed = Color(0xFFFFB4AB);
  static const Color errorContainerDark = Color(0xFF93000A);
  static const Color errorContainerLight = Color(0xFFFEE2E2);

  // Glassmorphic border stroke overlays
  static const Color glassBorderDark = Color(0x14FFFFFF); // 8% alpha white
  static const Color glassBorderLight = Color(
    0x140F172A,
  ); // 8% alpha dark slate
}
