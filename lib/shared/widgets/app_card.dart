import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// AppCard — themed content card with optional tap interaction.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.margin,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final overlay = isDark ? AppColors.overlayDark : AppColors.overlayLight;
    final resolvedRadius = borderRadius ?? AppRadius.mediumBR;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: resolvedRadius,
        boxShadow: AppShadow.level2,
      ),
      child: ClipRRect(
        borderRadius: resolvedRadius,
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                splashColor: overlay,
                highlightColor: overlay.withValues(alpha: 0.5),
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(AppSpacing.md),
                  child: child,
                ),
              )
            : Padding(
                padding: padding ?? const EdgeInsets.all(AppSpacing.md),
                child: child,
              ),
      ),
    );
  }
}
