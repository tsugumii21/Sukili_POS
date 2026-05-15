import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// CategoryPill — Horizontal filter chip for menu categories.
/// No emoji is rendered; category name text only.
class CategoryPill extends StatelessWidget {
  const CategoryPill({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedBg = isDark ? AppColors.accentDark : AppColors.accentLight;
    final unselectedBg =
        isDark ? AppColors.surfaceDarkElevated : AppColors.cardLight;
    final selectedText = AppColors.white;
    final unselectedText =
        isDark ? AppColors.textSecondaryDark : AppColors.textPrimaryLight;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : unselectedBg,
          borderRadius: BorderRadius.circular(99),
          border: isSelected
              ? null
              : Border.all(color: Colors.black.withValues(alpha: 0.06)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedBg.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            color: isSelected ? selectedText : unselectedText,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
