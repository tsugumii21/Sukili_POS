import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'app_button.dart';

/// ErrorStateWidget — shown when a screen or operation encounters an error.
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    required this.onRetry,
    this.message,
    this.title = 'Something went wrong',
  });

  final VoidCallback onRetry;
  final String? message;
  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final errorColor = isDark ? AppColors.errorDark : AppColors.errorLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: errorColor),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: primaryText,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  color: secondaryText,
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppPrimaryButton(
              label: 'Try Again',
              onPressed: onRetry,
              width: 200,
            ),
          ],
        ),
      ),
    );
  }
}
