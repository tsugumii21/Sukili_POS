import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/constants/route_constants.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';

/// VerifyEmailScreen — Shown after successful signup, prompts user to verify email.
class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;

    // Email passed via GoRouter extra
    final email = GoRouterState.of(context).extra as String? ?? 'your email';

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Icon ─────────────────────────────────────────────────
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_unread_rounded,
                    size: 52,
                    color: accent,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scaleXY(
                        begin: 0.8,
                        end: 1.0,
                        duration: 600.ms,
                        curve: Curves.easeOutBack),

                const SizedBox(height: AppSpacing.lg),

                // ── Title ────────────────────────────────────────────────
                Text(
                  'Check your email',
                  style: AppTextStyles.h1(context),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  'We sent a verification link to\n$email',
                  style: AppTextStyles.bodySecondary(context),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

                const SizedBox(height: AppSpacing.xl),

                // ── Instructions ─────────────────────────────────────────
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      _InstructionRow(
                        number: '1',
                        text: 'Open the email from Sukli POS',
                        accent: accent,
                      ),
                      _InstructionRow(
                        number: '2',
                        text: 'Tap the "Confirm Email" button',
                        accent: accent,
                      ),
                      _InstructionRow(
                        number: '3',
                        text: 'Come back and sign in below',
                        accent: accent,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

                const SizedBox(height: AppSpacing.xl),

                // ── Sign In button ───────────────────────────────────────
                AppPrimaryButton(
                  label: "I've Verified — Sign In",
                  onPressed: () => context.go(RouteConstants.adminLogin),
                ).animate().fadeIn(duration: 500.ms, delay: 600.ms),

                const SizedBox(height: AppSpacing.md),

                // ── Resend ───────────────────────────────────────────────
                AppTextButton(
                  label: 'Resend verification email',
                  onPressed: () => _resendEmail(context, email),
                ).animate().fadeIn(duration: 500.ms, delay: 700.ms),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _resendEmail(BuildContext context, String email) async {
    try {
      await SupabaseService.instance.auth.resend(
        type: sb.OtpType.signup,
        email: email,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification email resent!',
                style: AppTextStyles.bodySemiBold(context)
                    .copyWith(color: Colors.white)),
            backgroundColor: AppColors.successLight,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumBR),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not resend email. Try again later.',
                style: AppTextStyles.bodySemiBold(context)
                    .copyWith(color: Colors.white)),
            backgroundColor: AppColors.errorLight,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumBR),
          ),
        );
      }
    }
  }
}

/// A numbered instruction step row.
class _InstructionRow extends StatelessWidget {
  const _InstructionRow({
    required this.number,
    required this.text,
    required this.accent,
  });

  final String number;
  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: AppTextStyles.captionMedium(context)
                  .copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTextStyles.body(context))),
        ],
      ),
    );
  }
}
