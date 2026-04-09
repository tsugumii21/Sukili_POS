import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/admin_auth_provider.dart';

/// AdminLoginScreen — Supabase email/password auth for admin users.
/// Displays a centered card (max 400px) with Snackbar error handling.
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
    // Dismiss keyboard
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
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smallBR),
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.white, size: 18),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                'Invalid email or password. Please try again.',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 13,
                  fontFamily: 'DMSans',
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
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Back button ────────────────────────────────────────────────
            Positioned(
              top: AppSpacing.xs,
              left: AppSpacing.xs,
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: textPrimary, size: 20),
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
                        borderRadius: AppRadius.largeBR,
                        boxShadow: AppShadow.level3,
                      ),
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ── Logo ────────────────────────────────────────
                            Image.asset(
                              'assets/images/sukli_logo_transparent.png',
                              width: 80,
                              height: 80,
                            )
                                .animate()
                                .fadeIn(duration: 400.ms)
                                .scaleXY(
                                    begin: 0.8,
                                    end: 1.0,
                                    duration: 400.ms,
                                    curve: Curves.easeOutBack),

                            const SizedBox(height: AppSpacing.sm),

                            // ── App name ────────────────────────────────────
                            Text(
                              'Sukli POS',
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'DMSans',
                              ),
                            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                            // ── Subtitle ────────────────────────────────────
                            Text(
                              'Admin Portal',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.accentDark
                                    : AppColors.secondaryLight,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'DMSans',
                                letterSpacing: 1.2,
                              ),
                            ).animate().fadeIn(duration: 400.ms, delay: 150.ms),

                            const SizedBox(height: AppSpacing.xl),

                            // ── Email field ─────────────────────────────────
                            AppTextField(
                              controller: _emailController,
                              focusNode: _emailFocus,
                              label: 'Email',
                              hint: 'admin@suklibiz.com',
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              prefixIcon: Icon(Icons.email_outlined,
                                  color: textSecondary, size: 20),
                              onFieldSubmitted: (_) => FocusScope.of(context)
                                  .requestFocus(_passwordFocus),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!v.contains('@')) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                            const SizedBox(height: AppSpacing.md),

                            // ── Password field ──────────────────────────────
                            AppTextField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              label: 'Password',
                              hint: '••••••••',
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _login(),
                              prefixIcon: Icon(Icons.lock_outline_rounded,
                                  color: textSecondary, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: textSecondary,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Password is required';
                                }
                                return null;
                              },
                            ).animate().fadeIn(duration: 400.ms, delay: 250.ms),

                            const SizedBox(height: AppSpacing.xl),

                            // ── Login Button ────────────────────────────────
                            AppPrimaryButton(
                              label: 'Sign In',
                              onPressed: isLoading ? null : _login,
                              isLoading: isLoading,
                              icon: isLoading ? null : Icons.login_rounded,
                            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
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
