import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/isar_collections/user_collection.dart';
import '../providers/users_provider.dart';

/// UserTile — displays a single user row with avatar, name, email,
/// role chip, active toggle, and edit tap callback.
class UserTile extends ConsumerWidget {
  const UserTile({
    super.key,
    required this.user,
    required this.onTap,
    this.animationIndex = 0,
  });

  final UserCollection user;
  final VoidCallback onTap;
  final int animationIndex;

  static const _maroon = Color(0xFF8B4049);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';
    final isCashier = user.role == 'cashier';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: _maroon.withValues(alpha: 0.06),
          highlightColor: _maroon.withValues(alpha: 0.03),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                // ── Avatar ────────────────────────────────────────────────
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCashier
                        ? _maroon.withValues(alpha: 0.1)
                        : (isDark
                            ? AppColors.accentDark.withValues(alpha: 0.15)
                            : AppColors.accentLight.withValues(alpha: 0.12)),
                    border: Border.all(
                      color: isCashier
                          ? _maroon.withValues(alpha: 0.2)
                          : (isDark
                              ? AppColors.accentDark.withValues(alpha: 0.3)
                              : AppColors.accentLight.withValues(alpha: 0.25)),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: GoogleFonts.dmSans(
                        color: isCashier
                            ? _maroon
                            : (isDark
                                ? AppColors.accentDarkLight
                                : AppColors.accentLight),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // ── Name + email ──────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.dmSans(
                          color: textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.dmSans(
                          color: textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // ── Role chip ─────────────────────────────────────────────
                _RoleChip(role: user.role),
                const SizedBox(width: AppSpacing.sm),

                // ── Active toggle ─────────────────────────────────────────
                _ActiveToggle(user: user),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: animationIndex * 40))
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.06, end: 0);
  }
}

// ── Role Chip ─────────────────────────────────────────────────────────────────

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.role});
  final String role;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAdmin = role == 'admin';

    final bg = isAdmin
        ? (isDark
            ? const Color(0xFF8B4049).withValues(alpha: 0.25)
            : const Color(0xFF8B4049).withValues(alpha: 0.1))
        : (isDark
            ? AppColors.cardLight.withValues(alpha: 0.15)
            : AppColors.cardLight);

    final textColor = isAdmin
        ? const Color(0xFF8B4049)
        : (isDark ? AppColors.textSecondaryDark : const Color(0xFF6B4B3E));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isAdmin
              ? const Color(0xFF8B4049).withValues(alpha: 0.3)
              : AppColors.cardLight.withValues(alpha: isDark ? 0.2 : 0.5),
          width: 1,
        ),
      ),
      child: Text(
        isAdmin ? 'Admin' : 'Cashier',
        style: GoogleFonts.dmSans(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ── Active Toggle ─────────────────────────────────────────────────────────────

class _ActiveToggle extends ConsumerWidget {
  const _ActiveToggle({required this.user});
  final UserCollection user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = user.status == 'active';
    return Switch.adaptive(
      value: isActive,
      onChanged: (_) => ref.read(usersProvider.notifier).toggleStatus(user),
      activeThumbColor: const Color(0xFF8B4049),
      activeTrackColor: const Color(0xFF8B4049).withValues(alpha: 0.3),
      inactiveThumbColor: Colors.grey.shade400,
      inactiveTrackColor: Colors.grey.withValues(alpha: 0.15),
    );
  }
}
