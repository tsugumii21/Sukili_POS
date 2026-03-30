import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// AppTheme generates the Material 3 ThemeData for both light and dark modes.
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.accentLight,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      fontFamily: GoogleFonts.dmSans().fontFamily,
      
      colorScheme: const ColorScheme.light(
        primary: AppColors.accentLight,
        secondary: AppColors.secondaryLight,
        surface: AppColors.surfaceLight,
        error: AppColors.errorLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryLight,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
      ),

      cardTheme: CardTheme(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumBR),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentLight,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pillBR),
          textStyle: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentLight,
          side: const BorderSide(color: AppColors.accentLight),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pillBR),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.accentLight),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textSecondaryLight),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mediumBR,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mediumBR,
          borderSide: const BorderSide(color: AppColors.accentLight, width: 1.5),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.primaryLight,
        thickness: 1,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cardLight,
        selectedColor: AppColors.accentLight,
        labelStyle: GoogleFonts.dmSans(fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: const StadiumBorder(side: BorderSide.none),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimaryLight,
        contentTextStyle: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimaryDark),
      ),

      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.largeBR),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryDark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      fontFamily: GoogleFonts.dmSans().fontFamily,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        secondary: AppColors.secondaryDark,
        surface: AppColors.surfaceDark,
        error: AppColors.errorDark,
        onPrimary: AppColors.textPrimaryDark,
        onSecondary: AppColors.backgroundDark,
        onSurface: AppColors.textPrimaryDark,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
        ),
      ),

      cardTheme: CardTheme(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumBR),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentDark,
          foregroundColor: AppColors.primaryDark,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pillBR),
          textStyle: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentDark,
          side: const BorderSide(color: AppColors.accentDark),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pillBR),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.accentDark),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textSecondaryDark),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mediumBR,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mediumBR,
          borderSide: const BorderSide(color: AppColors.accentDark, width: 1.5),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceDark,
        thickness: 1,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cardDark,
        selectedColor: AppColors.accentDark,
        labelStyle: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textPrimaryDark),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: const StadiumBorder(side: BorderSide.none),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimaryDark,
        contentTextStyle: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimaryLight),
      ),

      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.largeBR),
      ),
    );
  }
}
