import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// PinPad — numeric keypad for PIN entry with dot indicators.
class PinPad extends StatelessWidget {
  const PinPad({
    super.key,
    required this.pin,
    required this.onKeyTap,
    required this.onDelete,
    this.hasError = false,
  });

  final String pin;
  final ValueChanged<String> onKeyTap;
  final VoidCallback onDelete;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PinDots(pin: pin, hasError: hasError),
        const SizedBox(height: AppSpacing.xl),
        _buildKeypad(context),
      ],
    );
  }

  Widget _buildKeypad(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              if (key.isEmpty) return const SizedBox(width: 80, height: 64);
              if (key == 'del') {
                return _KeyButton(
                  isDark: isDark,
                  onTap: onDelete,
                  child: Icon(
                    Icons.backspace_outlined,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    size: 22,
                  ),
                );
              }
              return _KeyButton(
                isDark: isDark,
                child: Text(
                  key,
                  style: GoogleFonts.dmSans(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () => onKeyTap(key),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Dot indicators ────────────────────────────────────────────────────────
class _PinDots extends StatelessWidget {
  const _PinDots({required this.pin, required this.hasError});

  final String pin;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = hasError
        ? (isDark ? AppColors.errorDark : AppColors.errorLight)
        : (isDark ? AppColors.accentDark : AppColors.accentLight);
    final inactiveColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final filled = index < pin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? activeColor : inactiveColor,
            border: Border.all(
              color: filled ? activeColor : activeColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
        );
      }),
    );
  }
}

// ─── Individual key button ─────────────────────────────────────────────────
class _KeyButton extends StatefulWidget {
  const _KeyButton({
    required this.child,
    required this.onTap,
    required this.isDark,
  });

  final Widget child;
  final VoidCallback onTap;
  final bool isDark;

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cardBg = widget.isDark ? AppColors.cardDark : AppColors.cardLight;
    final pressedBg =
        widget.isDark ? AppColors.surfaceDark : AppColors.primaryLight;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 80,
          height: 64,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: _pressed ? pressedBg : cardBg,
            borderRadius: AppRadius.mediumBR,
            boxShadow: AppShadow.level1,
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
