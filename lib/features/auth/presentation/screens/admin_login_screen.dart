import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/admin_auth_provider.dart';

/// AdminLoginScreen — Supabase email/password auth for admin users.
/// Redesigned with the modern fintech design system.
class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    try {
      final success = await ref.read(adminAuthProvider.notifier).signIn(
            _emailController.text,
            _passwordController.text,
          );

      if (success && mounted) {
        context.go(RouteConstants.adminHome);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(e.toString());
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.md),
        backgroundColor: AppColors.errorLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Invalid login credentials. Please try again.',
                style: GoogleFonts.dmSans(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(adminAuthProvider);
    final isLoading = authState.isLoading;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Back button ────────────────────────────────────────────────
            Positioned(
              top: AppSpacing.sm,
              left: AppSpacing.sm,
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
                onPressed: () => context.go(RouteConstants.cashierSelect),
              ),
            ),

            // ── Centered login card ────────────────────────────────────────
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 40,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ── Logo in rounded box ────────────────────────
                            Container(
                              width: 100,
                              height: 100,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundLight,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                              ),
                              child: Image.asset(
                                'assets/images/sukli_logo.png',
                                fit: BoxFit.contain,
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 600.ms)
                                .scaleXY(begin: 0.9, end: 1.0, duration: 600.ms, curve: Curves.easeOutBack),

                            const SizedBox(height: 32),

                            // ── App name ────────────────────────────────────
                            Text(
                              'Sukli',
                              style: GoogleFonts.dmSans(
                                color: textPrimary,
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.0,
                              ),
                            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                            // ── Subtitle ────────────────────────────────────
                            Text(
                              'ADMIN PORTAL',
                              style: GoogleFonts.dmSans(
                                color: const Color(0xFF8B4049),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 4.0,
                              ).copyWith(height: 1.5),
                            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                            const SizedBox(height: 48),

                            // ── Email field ─────────────────────────────────
                            AppTextField(
                              controller: _emailController,
                              focusNode: _emailFocus,
                              label: 'Admin Email',
                              hint: 'example@sukli.pos',
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              prefixIcon: Icon(Icons.alternate_email_rounded, color: textPrimary.withValues(alpha: 0.4), size: 20),
                              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Email is required';
                                return null;
                              },
                            ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

                            const SizedBox(height: 16),

                            // ── Password field ──────────────────────────────
                            AppTextField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              label: 'Password',
                              hint: '••••••••',
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _login(),
                              prefixIcon: Icon(Icons.lock_person_outlined, color: textPrimary.withValues(alpha: 0.4), size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: textPrimary.withValues(alpha: 0.4),
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Password is required';
                                return null;
                              },
                            ).animate().fadeIn(duration: 400.ms, delay: 500.ms),

                            const SizedBox(height: 40),

                            // ── Login Button ────────────────────────────────
                            AppPrimaryButton(
                              label: 'Sign In to Portal',
                              onPressed: isLoading ? null : _login,
                              isLoading: isLoading,
                              icon: isLoading ? null : Icons.shield_outlined,
                            ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
