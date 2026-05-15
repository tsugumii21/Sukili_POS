import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/isar_collections/user_collection.dart';
import '../providers/void_refund_provider.dart';

/// AdminPinDialog — A bottom-sheet dialog requiring admin PIN verification.
///
/// Shows a 4-dot indicator and a numeric keypad.
/// On success, returns the authenticated [UserCollection].
/// On cancellation, returns null.
///
/// Usage:
/// ```dart
/// final admin = await AdminPinDialog.show(context, notifier);
/// if (admin != null) { /* proceed */ }
/// ```
class AdminPinDialog extends StatefulWidget {
  const AdminPinDialog({
    super.key,
    required this.notifier,
    this.title = 'Admin Verification',
    this.subtitle = 'Enter your admin PIN to continue',
  });

  final VoidRefundNotifier notifier;
  final String title;
  final String subtitle;

  /// Shows the dialog and awaits the result.
  static Future<UserCollection?> show(
    BuildContext context,
    VoidRefundNotifier notifier, {
    String title = 'Admin Verification',
    String subtitle = 'Enter your admin PIN to continue',
  }) {
    return showModalBottomSheet<UserCollection?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdminPinDialog(
        notifier: notifier,
        title: title,
        subtitle: subtitle,
      ),
    );
  }

  @override
  State<AdminPinDialog> createState() => _AdminPinDialogState();
}

class _AdminPinDialogState extends State<AdminPinDialog>
    with SingleTickerProviderStateMixin {
  static const int _maxLength = 4;

  String _pin = '';
  bool _isVerifying = false;
  bool _hasError = false;
  String _errorText = '';

  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onDigit(String digit) {
    if (_pin.length >= _maxLength || _isVerifying) return;
    setState(() {
      _pin += digit;
      _hasError = false;
    });
    if (_pin.length == _maxLength) {
      _verify();
    }
  }

  void _onDelete() {
    if (_pin.isEmpty || _isVerifying) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _verify() async {
    setState(() => _isVerifying = true);
    HapticFeedback.lightImpact();

    final admin = await widget.notifier.verifyAdminPin(_pin);

    if (!mounted) return;

    if (admin != null) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop(admin);
    } else {
      HapticFeedback.heavyImpact();
      _shakeCtrl.forward(from: 0);
      setState(() {
        _isVerifying = false;
        _hasError = true;
        _errorText = 'Incorrect PIN. Try again.';
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.surfaceDark : AppColors.backgroundLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    const maroon = Color(0xFF8B4049);

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle bar ────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: textPrimary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(99),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
              child: Column(
                children: [
                  // ── Lock icon ──────────────────────────────────────────
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: maroon.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.lock_rounded, color: maroon, size: 26),
                  ).animate().scale(
                        begin: const Offset(0.8, 0.8),
                        duration: 300.ms,
                        curve: Curves.easeOut,
                      ),

                  const SizedBox(height: AppSpacing.md),

                  // ── Title & subtitle ───────────────────────────────────
                  Text(
                    widget.title,
                    style: AppTextStyles.h3(context),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: AppTextStyles.captionSecondary(context),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ── 4-dot PIN indicator ────────────────────────────────
                  AnimatedBuilder(
                    animation: _shakeAnim,
                    builder: (_, child) {
                      final offset = _hasError
                          ? (_shakeAnim.value * 8) *
                              (_shakeCtrl.lastElapsedDuration?.inMilliseconds
                                          .isOdd ??
                                      false
                                  ? 1
                                  : -1)
                          : 0.0;
                      return Transform.translate(
                        offset: Offset(offset, 0),
                        child: child,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_maxLength, (i) {
                        final filled = i < _pin.length;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: filled
                                ? (_hasError ? AppColors.errorLight : maroon)
                                : Colors.transparent,
                            border: Border.all(
                              color: filled
                                  ? (_hasError ? AppColors.errorLight : maroon)
                                  : textPrimary.withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // ── Error text ─────────────────────────────────────────
                  AnimatedSize(
                    duration: AppDuration.fast,
                    child: _hasError
                        ? Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              _errorText,
                              style:
                                  AppTextStyles.captionMedium(context).copyWith(
                                color: AppColors.errorLight,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),

            // ── Numeric keypad ────────────────────────────────────────────
            _PinKeypad(
              onDigit: _onDigit,
              onDelete: _onDelete,
              isVerifying: _isVerifying,
              isDark: isDark,
              maroon: maroon,
              textPrimary: textPrimary,
            ),

            // Bottom safe area padding
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Keypad
// ─────────────────────────────────────────────────────────────────────────────

class _PinKeypad extends StatelessWidget {
  const _PinKeypad({
    required this.onDigit,
    required this.onDelete,
    required this.isVerifying,
    required this.isDark,
    required this.maroon,
    required this.textPrimary,
  });

  final void Function(String) onDigit;
  final VoidCallback onDelete;
  final bool isVerifying;
  final bool isDark;
  final Color maroon;
  final Color textPrimary;

  static const _keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['', '0', 'del'],
  ];

  @override
  Widget build(BuildContext context) {
    final btnBg = isDark ? AppColors.surfaceDarkElevated : AppColors.cardLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: _keys.map((row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: row.map((key) {
                if (key.isEmpty) return const Expanded(child: SizedBox());

                final isDel = key == 'del';
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _KeyButton(
                      label: key,
                      isDel: isDel,
                      btnBg: btnBg,
                      maroon: maroon,
                      textPrimary: textPrimary,
                      enabled: !isVerifying,
                      onTap: isDel ? onDelete : () => onDigit(key),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.label,
    required this.isDel,
    required this.btnBg,
    required this.maroon,
    required this.textPrimary,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool isDel;
  final Color btnBg;
  final Color maroon;
  final Color textPrimary;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: enabled ? btnBg : btnBg.withValues(alpha: 0.5),
          borderRadius: AppRadius.mediumBR,
        ),
        alignment: Alignment.center,
        child: isDel
            ? Icon(Icons.backspace_outlined,
                size: 20, color: textPrimary.withValues(alpha: 0.6))
            : Text(
                label,
                style: AppTextStyles.h3(context),
              ),
      ),
    );
  }
}
