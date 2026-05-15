import 'package:flutter/material.dart';

/// AppColors defines the complete color palette for Sukli POS.
/// Includes specifics for both Beige Light and Maroon Dark modes.
class AppColors {
  // --- LIGHT MODE ---

  // Primaries
  static const Color primaryLight = Color(0xFFE8D5C4);
  static const Color primaryLightVariant = Color(0xFFF5E6D3);

  // Secondaries
  static const Color secondaryLight = Color(0xFF8B4049);
  static const Color secondaryLightVariant = Color(0xFFA0545C);

  // Accent
  static const Color accentLight = Color(0xFF6B2C33);

  // Backgrounds
  static const Color backgroundLight = Color(0xFFFAF6F1);
  static const Color backgroundLightWhite = Color(0xFFFFFFFF);

  // Surfaces
  static const Color surfaceLight = Color(0xFFF9F5F0);
  static const Color cardLight = Color(0xFFF0E8DC);

  // Text
  static const Color textPrimaryLight = Color(0xFF3E2723);
  static const Color textSecondaryLight = Color(0xFF5D4037);

  // Status
  static const Color successLight = Color(0xFF7B9971);
  static const Color warningLight = Color(0xFFD4A574);
  static const Color errorLight = Color(0xFFC2445B);

  // --- DARK MODE --- Dark Slate + Maroon Accent

  static const Color backgroundDark = Color(0xFF0F1117);
  static const Color backgroundDarkDeep = Color(0xFF090B0E);
  static const Color surfaceDark = Color(0xFF1C1F2A);
  static const Color surfaceDarkElevated = Color(0xFF252836);
  static const Color cardDark = Color(0xFF1C1F2A);
  static const Color borderDark = Color(0xFF2E3347);

  static const Color primaryDark = Color(0xFF1C1F2A);
  static const Color primaryDarkVariant = Color(0xFF252836);
  static const Color accentDark = Color(0xFFC4455A);
  static const Color accentDarkLight = Color(0xFFE8738A);
  static const Color secondaryDark = Color(0xFF8B92A8);

  static const Color textPrimaryDark = Color(0xFFF0F2F5);
  static const Color textSecondaryDark = Color(0xFF8B92A8);
  static const Color textDisabledDark = Color(0xFF4A5068);

  static const Color successDark = Color(0xFF4CAF82);
  static const Color warningDark = Color(0xFFF0A04B);
  static const Color errorDark = Color(0xFFE85A6F);

  // --- HELPERS ---

  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;

  static Color overlayLight = const Color(0xFF3E2723).withValues(alpha: 0.08);
  static Color overlayDark = const Color(0xFFFAF6F1).withValues(alpha: 0.08);
  static Color scrimLight = const Color(0xFF3E2723).withValues(alpha: 0.4);
  static Color scrimDark = const Color(0xFF1A0B0D).withValues(alpha: 0.6);
}
