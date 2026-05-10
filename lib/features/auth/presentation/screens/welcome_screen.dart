import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';

/// WelcomeScreen — First screen for new installs with no store configured.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSec = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.backgroundDarkDeep, AppColors.backgroundDark]
                : [AppColors.primaryLightVariant, AppColors.backgroundLight],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              children: [
                // ── Top spacer ───────────────────────────────────────────
                const Spacer(flex: 2),

                // ── App icon ─────────────────────────────────────────────
                Container(
                  width: 100,
                  height: 100,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: AppRadius.largeBR,
                    boxShadow: AppShadow.level3,
                  ),
                  child: Image.asset(
                    'assets/images/sukli_logo.png',
                    fit: BoxFit.contain,
                    color: Colors.white,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .scaleXY(
                        begin: 0.8,
                        end: 1.0,
                        duration: 800.ms,
                        curve: Curves.easeOutBack),

                const SizedBox(height: AppSpacing.lg),

                // ── Title ────────────────────────────────────────────────
                Text(
                  'Welcome to',
                  style: AppTextStyles.body(context).copyWith(color: textSec),
                ).animate().fadeIn(duration: 600.ms, delay: 300.ms),

                Text(
                  'Sukli POS',
                  style: GoogleFonts.dmSans(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.0,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  'Your all-in-one Point of Sale\nfor Philippine businesses.',
                  style: AppTextStyles.bodySecondary(context),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 600.ms, delay: 500.ms),

                // ── Feature highlights ───────────────────────────────────
                const SizedBox(height: AppSpacing.xl),

                _FeatureRow(
                  icon: Icons.wifi_off_rounded,
                  text: 'Works offline — always',
                  accent: accent,
                ).animate().fadeIn(duration: 400.ms, delay: 700.ms)
                    .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: 700.ms),

                _FeatureRow(
                  icon: Icons.sync_rounded,
                  text: 'Syncs to cloud automatically',
                  accent: accent,
                ).animate().fadeIn(duration: 400.ms, delay: 800.ms)
                    .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: 800.ms),

                _FeatureRow(
                  icon: Icons.people_outline_rounded,
                  text: 'Multi-cashier support',
                  accent: accent,
                ).animate().fadeIn(duration: 400.ms, delay: 900.ms)
                    .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: 900.ms),

                // ── Bottom actions ───────────────────────────────────────
                const Spacer(flex: 3),

                AppPrimaryButton(
                  label: 'Set Up My Store',
                  onPressed: () => context.go(RouteConstants.signup),
                ).animate().fadeIn(duration: 500.ms, delay: 1100.ms),

                const SizedBox(height: AppSpacing.md),

                AppTextButton(
                  label: 'I already have an account',
                  onPressed: () => context.go(RouteConstants.cashierSelect),
                ).animate().fadeIn(duration: 500.ms, delay: 1200.ms),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A single feature highlight row.
class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.text,
    required this.accent,
  });

  final IconData icon;
  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: SizedBox(
        height: 36,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: accent),
            const SizedBox(width: AppSpacing.xs),
            Text(text, style: AppTextStyles.bodySecondary(context)),
          ],
        ),
      ),
    );
  }
}
