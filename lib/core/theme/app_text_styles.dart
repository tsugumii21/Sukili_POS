import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// AppTextStyles provides the typography system for Sukli POS.
/// All styles use DM Sans via the google_fonts package.
/// Only splashTitle uses DM Serif Display (splash screen only).
class AppTextStyles {
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color _textPrimary(BuildContext context) =>
      _isDark(context) ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

  static Color _textSecondary(BuildContext context) => _isDark(context)
      ? AppColors.textSecondaryDark
      : AppColors.textSecondaryLight;

  // ── Splash — DM Serif Display (splash screen only) ───────────────────────

  static TextStyle splashTitle(BuildContext context) =>
      GoogleFonts.dmSerifDisplay(
        fontSize: 48,
        fontWeight: FontWeight.w400,
        color: _textPrimary(context),
      );

  // ── Headings ─────────────────────────────────────────────────────────────

  static TextStyle h1(BuildContext context) => GoogleFonts.dmSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: _textPrimary(context),
      );

  static TextStyle h2(BuildContext context) => GoogleFonts.dmSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: _textPrimary(context),
      );

  static TextStyle h3(BuildContext context) => GoogleFonts.dmSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: _textPrimary(context),
      );

  // ── Body ─────────────────────────────────────────────────────────────────

  static TextStyle bodyLarge(BuildContext context) => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: _textPrimary(context),
      );

  static TextStyle body(BuildContext context) => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: _textPrimary(context),
      );

  static TextStyle bodyMedium(BuildContext context) => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: _textPrimary(context),
      );

  static TextStyle bodySemiBold(BuildContext context) => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: _textPrimary(context),
      );

  static TextStyle bodySecondary(BuildContext context) => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: _textSecondary(context),
      );

  // ── Captions ─────────────────────────────────────────────────────────────

  static TextStyle caption(BuildContext context) => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: _textPrimary(context),
      );

  static TextStyle captionMedium(BuildContext context) => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: _textPrimary(context),
      );

  static TextStyle captionSemiBold(BuildContext context) => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: _textPrimary(context),
      );

  static TextStyle captionSecondary(BuildContext context) => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: _textSecondary(context),
      );

  // ── Labels ───────────────────────────────────────────────────────────────

  static TextStyle label(BuildContext context) => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: _textPrimary(context),
      );

  // ── Price display ─────────────────────────────────────────────────────────

  static TextStyle priceDisplay(BuildContext context) => GoogleFonts.dmSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: _textPrimary(context),
      );

  static TextStyle priceSmall(BuildContext context) => GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _textPrimary(context),
      );
}
