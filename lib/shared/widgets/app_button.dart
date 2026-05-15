import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppPrimaryButton — filled pill button with Plus Jakarta Sans and press animation
// ─────────────────────────────────────────────────────────────────────────────
class AppPrimaryButton extends StatefulWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  @override
  State<AppPrimaryButton> createState() => _AppPrimaryButtonState();
}

class _AppPrimaryButtonState extends State<AppPrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.accentDark : AppColors.accentLight;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: 60, // Slightly taller for a more premium tap target
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: (widget.isLoading || widget.onPressed == null)
                  ? bg.withValues(alpha: 0.5)
                  : bg,
              borderRadius: BorderRadius.circular(18), // Modern rounded corners
              boxShadow: _isPressed
                  ? []
                  : [
                      BoxShadow(
                        color: bg.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator.adaptive(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.white),
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: AppColors.white, size: 20),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          widget.label,
                          style: GoogleFonts.dmSans(
                            color: AppColors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppSecondaryButton — outlined button with Inter
// ─────────────────────────────────────────────────────────────────────────────
class AppSecondaryButton extends StatefulWidget {
  const AppSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  @override
  State<AppSecondaryButton> createState() => _AppSecondaryButtonState();
}

class _AppSecondaryButtonState extends State<AppSecondaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.accentDark : AppColors.accentLight;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: 60,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.transparent,
              border:
                  Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator.adaptive(
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: color, size: 20),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          widget.label,
                          style: GoogleFonts.dmSans(
                            color: color,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppTextButton — minimal text-only button with Plus Jakarta Sans
// ─────────────────────────────────────────────────────────────────────────────
class AppTextButton extends StatelessWidget {
  const AppTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.underline = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool underline;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.accentDark : AppColors.accentLight;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        foregroundColor: color,
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          color: color,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          decoration: underline ? TextDecoration.underline : null,
          decorationColor: color,
        ),
      ),
    );
  }
}
