import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/services/sync_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/sync_provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../auth/presentation/providers/admin_auth_provider.dart';
import '../providers/admin_dashboard_provider.dart';

/// AdminDashboardScreen — the main home screen for administrators.
/// Displays daily stats, quick action grid, sync controls, and recent orders.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(adminDashboardProvider);
    final adminUser = ref.watch(adminAuthProvider).value;
    final isOnline = ref.watch(isOnlineProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    // Derive avatar initial from admin email or fallback
    final email = adminUser?.email ?? '';
    final initial = email.isNotEmpty ? email[0].toUpperCase() : 'A';

    return Scaffold(
      backgroundColor: bg,
      drawer: _AdminNavDrawer(adminEmail: email),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 60,
        // All content in flexibleSpace — prevents NavigationToolbar overflow.
        automaticallyImplyLeading: false,
        flexibleSpace: Builder(
          builder: (ctx) => SafeArea(
            bottom: false,
            child: SizedBox(
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Drawer button
                  SizedBox(
                    width: 48,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.menu_rounded,
                          color: textPrimary, size: 28),
                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                    ),
                  ),
                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Sukli POS',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: AppTextStyles.bodySemiBold(context)
                              .copyWith(color: textPrimary),
                        ),
                        Text(
                          'Admin',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: AppTextStyles.caption(context).copyWith(
                            color: textPrimary.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Connectivity dot
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOnline
                          ? AppColors.successLight
                          : AppColors.errorLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Avatar
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isDark
                        ? AppColors.accentDark.withValues(alpha: 0.2)
                        : AppColors.accentLight.withValues(alpha: 0.15),
                    child: Text(
                      initial,
                      style: GoogleFonts.dmSans(
                        color: isDark
                            ? AppColors.accentDarkLight
                            : AppColors.accentLight,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // Logout button
                  IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.logout_rounded,
                        color: AppColors.errorLight, size: 22),
                    onPressed: () => _confirmLogout(context, ref),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
        ),
      ),
      body: dashboardAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (err, _) =>
            Center(child: Text('Error loading dashboard: $err')),
        data: (data) => SafeArea(
          top: false,
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(adminDashboardProvider.notifier).refreshData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stats Grid ────────────────────────────────────────────
                  _SectionLabel(label: 'Overview', context: context),
                  const SizedBox(height: AppSpacing.sm),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 1.55,
                    children: [
                      _AdminStatCard(
                        icon: Icons.payments_outlined,
                        value: CurrencyFormatter.formatCompact(
                            data.totalSalesToday),
                        label: "Total Sales Today",
                        accentColor: const Color(0xFF8B4049),
                        delay: 0,
                      ),
                      _AdminStatCard(
                        icon: Icons.shopping_bag_outlined,
                        value: data.ordersToday.toString(),
                        label: "Orders Today",
                        accentColor: AppColors.successLight,
                        delay: 80,
                      ),
                      _AdminStatCard(
                        icon: Icons.sync_rounded,
                        value: data.pendingSyncCount.toString(),
                        label: "Pending Sync",
                        accentColor: data.pendingSyncCount > 0
                            ? AppColors.warningLight
                            : AppColors.successLight,
                        delay: 240,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Quick Actions ─────────────────────────────────────────
                  _SectionLabel(label: 'Quick Actions', context: context),
                  const SizedBox(height: AppSpacing.sm),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 2.6,
                    children: [
                      _QuickActionCard(
                        icon: Icons.people_outline_rounded,
                        label: 'Users',
                        delay: 0,
                        onTap: () => context.push(RouteConstants.adminUsers),
                      ),
                      _QuickActionCard(
                        icon: Icons.restaurant_menu_rounded,
                        label: 'Menu',
                        delay: 60,
                        onTap: () =>
                            context.push(RouteConstants.adminMenuItems),
                      ),
                      _QuickActionCard(
                        icon: Icons.remove_circle_outline_rounded,
                        label: 'Voids',
                        delay: 180,
                        onTap: () => context.push(RouteConstants.adminVoids),
                      ),
                      _QuickActionCard(
                        icon: Icons.bar_chart_rounded,
                        label: 'Reports',
                        delay: 240,
                        onTap: () =>
                            context.push(RouteConstants.adminReports),
                      ),
                      _QuickActionCard(
                        icon: Icons.night_shelter_outlined,
                        label: 'End of Day',
                        delay: 300,
                        onTap: () =>
                            context.push(RouteConstants.adminEndOfDay),
                      ),
                      _QuickActionCard(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        delay: 360,
                        onTap: () =>
                            context.push(RouteConstants.adminSettings),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Sync Now ──────────────────────────────────────────────
                  _SyncNowButton(ref: ref),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Recent Activity ───────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionLabel(
                          label: 'Recent Activity', context: context),
                      TextButton(
                        onPressed: () =>
                            context.push(RouteConstants.orderHistory),
                        child: Text(
                          'See All',
                          style: GoogleFonts.dmSans(
                            color: const Color(0xFF8B4049),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  if (data.recentOrders.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Center(
                        child: Text(
                          'No orders yet.',
                          style: AppTextStyles.bodySecondary(context),
                        ),
                      ),
                    )
                  else
                    ...data.recentOrders.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final order = entry.value;
                      return _RecentOrderTile(order: order, index: idx);
                    }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.dmSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text('Cancel', style: GoogleFonts.dmSans()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(
              'Logout',
              style: GoogleFonts.dmSans(
                color: AppColors.errorLight,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(adminAuthProvider.notifier).signOut();
      if (context.mounted) context.go(RouteConstants.adminLogin);
    }
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.context});
  final String label;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Text(
      label,
      style: GoogleFonts.dmSans(
        color: Theme.of(ctx).brightness == Brightness.dark
            ? AppColors.textPrimaryDark
            : AppColors.textPrimaryLight,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    );
  }
}

// ── Admin Stat Card ───────────────────────────────────────────────────────────

class _AdminStatCard extends StatelessWidget {
  const _AdminStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.accentColor,
    this.delay = 0,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color accentColor;
  final int delay;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Per spec: card=#F0E8DC light / #5D2832 dark
    final cardBg =
        isDark ? const Color(0xFF5D2832) : AppColors.cardLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon + label row
          Row(
            children: [
              Icon(icon, size: 16, color: accentColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: GoogleFonts.dmSans(
                    color: textPrimary.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          // Value
          Text(
            value,
            style: GoogleFonts.dmSans(
              color: textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.08, end: 0);
  }
}

// ── Quick Action Card ─────────────────────────────────────────────────────────

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
    this.delay = 0,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int delay;

  static const _maroon = Color(0xFF8B4049);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: _maroon.withValues(alpha: 0.08),
        highlightColor: _maroon.withValues(alpha: 0.04),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              Icon(icon, size: 22, color: _maroon),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    color: textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: textPrimary.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 350.ms)
        .slideX(begin: 0.06, end: 0, curve: Curves.easeOut);
  }
}

// ── Sync Now Button ───────────────────────────────────────────────────────────

class _SyncNowButton extends ConsumerStatefulWidget {
  const _SyncNowButton({required this.ref});
  final WidgetRef ref;

  @override
  ConsumerState<_SyncNowButton> createState() => _SyncNowButtonState();
}

class _SyncNowButtonState extends ConsumerState<_SyncNowButton> {
  bool _isSyncing = false;

  Future<void> _sync() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    try {
      await SyncService.instance.syncAll();
      await ref.read(adminDashboardProvider.notifier).refreshData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sync complete.',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.successLight,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sync failed: $e',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.errorLight,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineProvider);

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: (isOnline && !_isSyncing) ? _sync : null,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF8B4049),
          disabledBackgroundColor: const Color(0xFF8B4049).withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: _isSyncing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.sync_rounded, color: Colors.white, size: 20),
        label: Text(
          _isSyncing
              ? 'Syncing…'
              : isOnline
                  ? 'Sync Now'
                  : 'Offline — Cannot Sync',
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

// ── Recent Order Tile ─────────────────────────────────────────────────────────

class _RecentOrderTile extends StatelessWidget {
  const _RecentOrderTile({required this.order, required this.index});

  final dynamic order; // OrderCollection
  final int index;

  static const _maroon = Color(0xFF8B4049);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final rawNum = order.orderNumber as String;
    final shortNum =
        '#${rawNum.length > 4 ? rawNum.substring(rawNum.length - 4) : rawNum}';

    Color statusColor;
    String statusLabel;
    switch (order.status as String) {
      case 'completed':
        statusColor = AppColors.successLight;
        statusLabel = 'Completed';
        break;
      case 'voided':
        statusColor = AppColors.errorLight;
        statusLabel = 'Voided';
        break;
      default:
        statusColor = AppColors.warningLight;
        statusLabel = (order.status as String).toUpperCase();
    }

    final orderedAt = order.orderedAt as DateTime;
    final timeStr =
        '${orderedAt.hour.toString().padLeft(2, '0')}:${orderedAt.minute.toString().padLeft(2, '0')}';
    final dateStr =
        '${orderedAt.day}/${orderedAt.month}/${orderedAt.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status accent bar
              Container(width: 3, color: statusColor),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _maroon.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.receipt_long_rounded,
                            color: _maroon, size: 18),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // Order info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              shortNum,
                              style: GoogleFonts.dmSans(
                                color: textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '$dateStr · $timeStr · ${order.cashierName}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: GoogleFonts.dmSans(
                                color: textPrimary.withValues(alpha: 0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Right side: amount + status
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            CurrencyFormatter.format(
                                order.totalAmount as double),
                            style: GoogleFonts.dmSans(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              statusLabel,
                              style: GoogleFonts.dmSans(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 40))
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.06, end: 0);
  }
}

// ── Admin Navigation Drawer ───────────────────────────────────────────────────

class _AdminNavDrawer extends ConsumerWidget {
  const _AdminNavDrawer({required this.adminEmail});
  final String adminEmail;

  static const _maroon = Color(0xFF8B4049);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final drawerBg = isDark ? const Color(0xFF2A1215) : Colors.white;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final itemHoverBg =
        isDark ? const Color(0xFF3E2723) : const Color(0xFFF9F0F1);
    final initial =
        adminEmail.isNotEmpty ? adminEmail[0].toUpperCase() : 'A';

    return Drawer(
      backgroundColor: drawerBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Profile header ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: _maroon,
              borderRadius: BorderRadius.only(topRight: Radius.circular(28)),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 28,
              left: 28,
              right: 28,
              bottom: 28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ).animate().scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    ),

                const SizedBox(height: 14),

                // Email
                Text(
                  adminEmail.isNotEmpty ? adminEmail : 'Admin',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ).animate().fadeIn(duration: 350.ms, delay: 80.ms),

                const SizedBox(height: 6),

                // Role chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    'Administrator',
                    style: GoogleFonts.dmSans(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ).animate().fadeIn(duration: 350.ms, delay: 140.ms),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Nav section label ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Text(
              'NAVIGATION',
              style: GoogleFonts.dmSans(
                color: textPrimary.withValues(alpha: 0.35),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 160.ms),

          const SizedBox(height: 4),

          // ── Nav items ──────────────────────────────────────────────────
          _AdminNavItem(
            icon: Icons.dashboard_rounded,
            label: 'Home',
            delay: 180,
            onTap: () => Navigator.pop(context),
            hoverBg: itemHoverBg,
            textColor: textPrimary,
          ),
          _AdminNavItem(
            icon: Icons.restaurant_menu_rounded,
            label: 'Menu',
            delay: 220,
            onTap: () {
              Navigator.pop(context);
              context.push(RouteConstants.adminMenuItems);
            },
            hoverBg: itemHoverBg,
            textColor: textPrimary,
          ),
          _AdminNavItem(
            icon: Icons.bar_chart_rounded,
            label: 'Reports',
            delay: 300,
            onTap: () {
              Navigator.pop(context);
              context.push(RouteConstants.adminReports);
            },
            hoverBg: itemHoverBg,
            textColor: textPrimary,
          ),
          _AdminNavItem(
            icon: Icons.settings_rounded,
            label: 'Settings',
            delay: 340,
            onTap: () {
              Navigator.pop(context);
              context.push(RouteConstants.adminSettings);
            },
            hoverBg: itemHoverBg,
            textColor: textPrimary,
          ),

          const Spacer(),

          // ── Footer divider ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              color: textPrimary.withValues(alpha: 0.08),
              height: 1,
            ),
          ),

          const SizedBox(height: 8),

          // ── Theme toggle ───────────────────────────────────────────────
          _AdminThemeToggleTile(
            textColor: textPrimary,
            hoverBg: itemHoverBg,
          ),

          // ── Logout ─────────────────────────────────────────────────────
          _AdminNavItem(
            icon: Icons.power_settings_new_rounded,
            label: 'Logout',
            delay: 0,
            iconColor: AppColors.errorLight,
            textColor: AppColors.errorLight,
            hoverBg: AppColors.errorLight.withValues(alpha: 0.07),
            onTap: () async {
              Navigator.pop(context);
              await ref.read(adminAuthProvider.notifier).signOut();
              if (context.mounted) context.go(RouteConstants.adminLogin);
            },
          ),

          SizedBox(
            height: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
          ),
        ],
      ),
    );
  }
}

/// A single tappable row in the admin navigation drawer.
class _AdminNavItem extends StatelessWidget {
  const _AdminNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.hoverBg,
    required this.textColor,
    this.iconColor,
    this.delay = 0,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color hoverBg;
  final Color textColor;
  final Color? iconColor;
  final int delay;

  @override
  Widget build(BuildContext context) {
    final ic = iconColor ?? textColor;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: ic.withValues(alpha: 0.1),
          highlightColor: hoverBg,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 21, color: ic),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 280.ms, delay: delay.ms)
        .slideX(
          begin: -0.06,
          end: 0,
          duration: 280.ms,
          delay: delay.ms,
          curve: Curves.easeOut,
        );
  }
}

/// Theme toggle row in the admin drawer footer.
class _AdminThemeToggleTile extends ConsumerWidget {
  const _AdminThemeToggleTile({
    required this.textColor,
    required this.hoverBg,
  });

  final Color textColor;
  final Color hoverBg;

  static const _maroon = Color(0xFF8B4049);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => ref.read(themeProvider.notifier).toggle(),
          borderRadius: BorderRadius.circular(14),
          splashColor: textColor.withValues(alpha: 0.08),
          highlightColor: hoverBg,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(
                  isDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  size: 21,
                  color: isDark ? AppColors.accentDarkLight : _maroon,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    isDark ? 'Dark Mode' : 'Light Mode',
                    style: GoogleFonts.dmSans(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Switch.adaptive(
                  value: isDark,
                  onChanged: (_) =>
                      ref.read(themeProvider.notifier).toggle(),
                  activeThumbColor: AppColors.accentDark,
                  activeTrackColor:
                      AppColors.accentDark.withValues(alpha: 0.5),
                  inactiveThumbColor: _maroon,
                  inactiveTrackColor: _maroon.withValues(alpha: 0.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
