import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/auth_provider.dart';
import '../widgets/pin_pad.dart';

/// CashierPinScreen — PIN entry with shake animation on wrong attempt.
class CashierPinScreen extends ConsumerStatefulWidget {
  const CashierPinScreen({super.key});

  @override
  ConsumerState<CashierPinScreen> createState() => _CashierPinScreenState();
}

class _CashierPinScreenState extends ConsumerState<CashierPinScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  bool _hasError = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeyTap(String key) {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += key;
      _hasError = false;
    });

    // Auto-submit on 4th digit
    if (_pin.length == 4) {
      _submitPin();
    }
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _hasError = false;
    });
  }

  Future<void> _submitPin() async {
    final success = await ref.read(authProvider.notifier).verifyPin(_pin);

    if (!mounted) return;

    if (success) {
      context.go(RouteConstants.cashierHome);
    } else {
      // Shake + red flash
      setState(() => _hasError = true);
      await _shakeController.forward();
      await Future.delayed(const Duration(milliseconds: 600));
      _shakeController.reset();
      setState(() {
        _pin = '';
        _hasError = false;
      });
      ref.read(authProvider.notifier).clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final avatarBg = isDark ? AppColors.primaryDark : AppColors.accentLight;

    final cashier = ref.watch(authProvider).selectedCashier;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: textPrimary, size: 20),
          onPressed: () {
            ref.read(authProvider.notifier).clearSelection();
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteConstants.cashierSelect);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.lg),

                // ── Cashier Avatar ─────────────────────────────────────────
                if (cashier != null) ...[
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: avatarBg,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        cashier.name[0].toUpperCase(),
                        style: GoogleFonts.dmSans(
                          color: AppColors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    cashier.name,
                    style: GoogleFonts.dmSans(
                      color: textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                  const SizedBox(height: 4),
                  Text(
                    'Enter your PIN',
                    style: GoogleFonts.dmSans(
                      color: textSecondary,
                      fontSize: 14,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 150.ms),
                ],

                const SizedBox(height: AppSpacing.xl),

                // ── PIN Pad with shake ─────────────────────────────────────
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    final shakeOffset = _shakeAnimation.value == 0
                        ? 0.0
                        : ((_shakeAnimation.value * 4).round() % 2 == 0
                                ? 12.0
                                : -12.0) *
                            (1 - _shakeAnimation.value);
                    return Transform.translate(
                      offset: Offset(shakeOffset, 0),
                      child: child,
                    );
                  },
                  child: PinPad(
                    pin: _pin,
                    hasError: _hasError,
                    onKeyTap: _onKeyTap,
                    onDelete: _onDelete,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                const SizedBox(height: AppSpacing.xl),

                // ── Error message ──────────────────────────────────────────
                if (_hasError)
                  Text(
                    'Incorrect PIN. Try again.',
                    style: GoogleFonts.dmSans(
                      color:
                          isDark ? AppColors.errorDark : AppColors.errorLight,
                      fontSize: 13,
                    ),
                  ).animate().fadeIn(duration: 200.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
