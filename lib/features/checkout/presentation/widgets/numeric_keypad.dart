import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

/// 3×4 numeric keypad for cash amount entry.
///
/// Layout:
///   7  8  9
///   4  5  6
///   1  2  3
///   .  0  ⌫
class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    required this.onDigit,
    required this.onDelete,
  });

  final void Function(String digit) onDigit;
  final VoidCallback onDelete;

  static const _rows = [
    ['7', '8', '9'],
    ['4', '5', '6'],
    ['1', '2', '3'],
    ['.', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Column(
      children: _rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: row.map((key) {
              final isBackspace = key == '⌫';
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _KeyButton(
                    label: key,
                    bg: keyBg,
                    textColor: textColor,
                    isBackspace: isBackspace,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      isBackspace ? onDelete() : onDigit(key);
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.label,
    required this.bg,
    required this.textColor,
    required this.onTap,
    this.isBackspace = false,
  });

  final String label;
  final Color bg;
  final Color textColor;
  final VoidCallback onTap;
  final bool isBackspace;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: const Color(0xFF8B4049).withValues(alpha: 0.12),
        highlightColor: const Color(0xFF8B4049).withValues(alpha: 0.06),
        child: Ink(
          height: 60,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: isBackspace
                ? Icon(
                    Icons.backspace_outlined,
                    color: textColor.withValues(alpha: 0.55),
                    size: 22,
                  )
                : Text(
                    label,
                    style: GoogleFonts.dmSans(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
