import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/isar_collections/order_collection.dart';
import '../providers/void_refund_provider.dart';
import '../widgets/admin_pin_dialog.dart';
import '../widgets/refund_sheet.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VoidRefundScreen — 3-tab view: Void Orders | Refunds | History
// ─────────────────────────────────────────────────────────────────────────────

class VoidRefundScreen extends ConsumerStatefulWidget {
  const VoidRefundScreen({super.key});

  @override
  ConsumerState<VoidRefundScreen> createState() => _VoidRefundScreenState();
}

class _VoidRefundScreenState extends ConsumerState<VoidRefundScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  static const _tabs = [
    Tab(text: 'Void Orders'),
    Tab(text: 'Refunds'),
    Tab(text: 'History'),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      if (_tabCtrl.indexIsChanging) return;
      final t = VoidRefundTab.values[_tabCtrl.index];
      ref.read(voidRefundProvider.notifier).selectTab(t);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(voidRefundProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    const maroon = Color(0xFF8B4049);

    // Show error snackbar if present
    ref.listen<VoidRefundState>(voidRefundProvider, (_, next) {
      if (next.errorMessage != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!,
                style: GoogleFonts.dmSans(color: Colors.white)),
            backgroundColor: AppColors.errorLight,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: AppRadius.mediumBR),
          ),
        );
        ref.read(voidRefundProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: textPrimary, size: 20),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          'Voids & Refunds',
          style: GoogleFonts.dmSans(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: _tabs,
          labelStyle:
              GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700),
          unselectedLabelStyle:
              GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
          labelColor: maroon,
          unselectedLabelColor: textPrimary.withValues(alpha: 0.45),
          indicatorColor: maroon,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
        ),
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF8B4049)))
          : TabBarView(
              controller: _tabCtrl,
              children: [
                // Tab 0 — Void Orders
                _OrdersTab(
                  orders: state.voidableOrders,
                  mode: _TabMode.voidOrder,
                  emptyTitle: 'No completed orders',
                  emptySubtitle:
                      'Completed orders available for voiding will appear here.',
                  isDark: isDark,
                ),

                // Tab 1 — Refunds
                _OrdersTab(
                  orders: state.refundableOrders,
                  mode: _TabMode.refund,
                  emptyTitle: 'No refundable orders',
                  emptySubtitle:
                      'Completed orders eligible for refunds will appear here.',
                  isDark: isDark,
                ),

                // Tab 2 — History
                _OrdersTab(
                  orders: state.historyOrders,
                  mode: _TabMode.history,
                  emptyTitle: 'No history yet',
                  emptySubtitle:
                      'All voided and refunded orders will appear here.',
                  isDark: isDark,
                  sortable: true,
                ),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab mode
// ─────────────────────────────────────────────────────────────────────────────

enum _TabMode { voidOrder, refund, history }

// ─────────────────────────────────────────────────────────────────────────────
// Orders tab
// ─────────────────────────────────────────────────────────────────────────────

class _OrdersTab extends ConsumerStatefulWidget {
  const _OrdersTab({
    required this.orders,
    required this.mode,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.isDark,
    this.sortable = false,
  });

  final List<OrderCollection> orders;
  final _TabMode mode;
  final String emptyTitle;
  final String emptySubtitle;
  final bool isDark;
  final bool sortable;

  @override
  ConsumerState<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends ConsumerState<_OrdersTab> {
  bool _newestFirst = true;

  List<OrderCollection> get _sorted {
    final list = List<OrderCollection>.from(widget.orders);
    list.sort((a, b) => _newestFirst
        ? b.orderedAt.compareTo(a.orderedAt)
        : a.orderedAt.compareTo(b.orderedAt));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    const maroon = Color(0xFF8B4049);

    if (widget.orders.isEmpty) {
      return _EmptyState(
        title: widget.emptyTitle,
        subtitle: widget.emptySubtitle,
        isDark: isDark,
      );
    }

    final items = _sorted;

    return Column(
      children: [
        // ── Sort row (History tab only) ─────────────────────────────────
        if (widget.sortable)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () =>
                      setState(() => _newestFirst = !_newestFirst),
                  child: Row(
                    children: [
                      Icon(
                        _newestFirst
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        size: 14,
                        color: maroon,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _newestFirst ? 'Newest first' : 'Oldest first',
                        style: GoogleFonts.dmSans(
                          color: maroon,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // ── Order list ──────────────────────────────────────────────────
        Expanded(
          child: RefreshIndicator(
            color: maroon,
            backgroundColor:
                isDark ? AppColors.surfaceDark : Colors.white,
            onRefresh: () async {
              // Provider auto-refreshes via watchLazy — force a UI rebuild
              ref.invalidate(voidRefundProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: items.length,
              itemBuilder: (_, i) {
                return _OrderRow(
                  order: items[i],
                  mode: widget.mode,
                  isDark: isDark,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ).animate().fadeIn(
                      duration: 250.ms,
                      delay: Duration(milliseconds: i * 40),
                    );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single order row card
// ─────────────────────────────────────────────────────────────────────────────

class _OrderRow extends ConsumerWidget {
  const _OrderRow({
    required this.order,
    required this.mode,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

  final OrderCollection order;
  final _TabMode mode;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  static final _timeFmt = DateFormat('MMM d, h:mm a');

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.successLight;
      case 'voided':
        return AppColors.errorLight;
      case 'refunded':
        return AppColors.warningLight;
      default:
        return AppColors.textSecondaryLight;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const maroon = Color(0xFF8B4049);
    final cardBg = isDark ? AppColors.cardDark : const Color(0xFFF0E8DC);
    final statusColor = _statusColor(order.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.largeBR,
        border: isDark
            ? Border.all(color: AppColors.borderDark)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            // ── Status accent bar ──────────────────────────────────────
            Container(
              width: 4,
              height: 56,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // ── Order info ─────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.orderNumber,
                    style: GoogleFonts.dmSans(
                      color: textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${order.cashierName}  ·  ${_timeFmt.format(order.orderedAt)}',
                    style: GoogleFonts.dmSans(
                      color: textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // ── Total + action ─────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.format(order.totalAmount),
                  style: GoogleFonts.dmSans(
                    color: maroon,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                _ActionButton(
                  order: order,
                  mode: mode,
                  isDark: isDark,
                  maroon: maroon,
                  statusColor: statusColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action button (Void / Refund / status chip for History)
// ─────────────────────────────────────────────────────────────────────────────

class _ActionButton extends ConsumerWidget {
  const _ActionButton({
    required this.order,
    required this.mode,
    required this.isDark,
    required this.maroon,
    required this.statusColor,
  });

  final OrderCollection order;
  final _TabMode mode;
  final bool isDark;
  final Color maroon;
  final Color statusColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // History tab — show a read-only status chip
    if (mode == _TabMode.history) {
      return Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          _capitalize(order.status),
          style: GoogleFonts.dmSans(
            color: statusColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    // Void / Refund action buttons
    final isVoid = mode == _TabMode.voidOrder;
    final label = isVoid ? 'Void' : 'Refund';
    final color = isVoid ? AppColors.errorLight : AppColors.warningLight;

    return GestureDetector(
      onTap: () => isVoid
          ? _handleVoid(context, ref)
          : _handleRefund(context, ref),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ── Void flow ─────────────────────────────────────────────────────────────

  Future<void> _handleVoid(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(voidRefundProvider.notifier);

    // Step 1 — Admin PIN
    final admin = await AdminPinDialog.show(
      context,
      notifier,
      title: 'Admin Verification',
      subtitle: 'Enter admin PIN to void this order',
    );
    if (admin == null || !context.mounted) return;

    // Step 2 — Reason dialog
    final reason = await _showReasonDialog(context);
    if (reason == null || !context.mounted) return;

    // Step 3 — Process void
    final ok = await notifier.voidOrder(
      order: order,
      admin: admin,
      reason: reason,
    );

    if (context.mounted) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok ? '${order.orderNumber} voided successfully.' : 'Void failed.',
            style: GoogleFonts.dmSans(color: Colors.white),
          ),
          backgroundColor: ok ? AppColors.successLight : AppColors.errorLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumBR),
        ),
      );
    }
  }

  Future<String?> _showReasonDialog(BuildContext context) async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogCtx) {
        final isDark =
            Theme.of(dialogCtx).brightness == Brightness.dark;
        final dialogBg =
            isDark ? AppColors.surfaceDark : AppColors.backgroundLight;
        final textPrimary = isDark
            ? AppColors.textPrimaryDark
            : AppColors.textPrimaryLight;
        final textSecondary = isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight;

        return AlertDialog(
          backgroundColor: dialogBg,
          shape:
              RoundedRectangleBorder(borderRadius: AppRadius.largeBR),
          title: Text(
            'Void Reason',
            style: GoogleFonts.dmSans(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            maxLines: 3,
            style: GoogleFonts.dmSans(color: textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter void reason (required)',
              hintStyle: GoogleFonts.dmSans(
                  color: textSecondary, fontSize: 13),
              filled: true,
              fillColor: isDark
                  ? AppColors.cardDark
                  : AppColors.cardLight,
              border: OutlineInputBorder(
                borderRadius: AppRadius.mediumBR,
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.sm),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(null),
              child: Text('Cancel',
                  style: GoogleFonts.dmSans(color: textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                final reason = ctrl.text.trim();
                if (reason.isEmpty) return;
                Navigator.of(dialogCtx).pop(reason);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorLight,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mediumBR),
              ),
              child: Text('Confirm Void',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  // ── Refund flow ──────────────────────────────────────────────────────────

  Future<void> _handleRefund(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(voidRefundProvider.notifier);

    // Step 1 — RefundSheet (choose type + reason)
    final result = await RefundSheet.show(context, order);
    if (result == null || !context.mounted) return;

    // Step 2 — Admin PIN
    final admin = await AdminPinDialog.show(
      context,
      notifier,
      title: 'Confirm Refund',
      subtitle: 'Enter admin PIN to process the refund',
    );
    if (admin == null || !context.mounted) return;

    // Step 3 — Process refund
    final ok = await notifier.refundOrder(
      order: order,
      admin: admin,
      reason: result.reason,
      refundAmount: result.amount,
      isPartial: result.isPartial,
    );

    if (context.mounted) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? '${order.orderNumber} refunded ${CurrencyFormatter.format(result.amount)}.'
                : 'Refund failed.',
            style: GoogleFonts.dmSans(color: Colors.white),
          ),
          backgroundColor:
              ok ? AppColors.successLight : AppColors.errorLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumBR),
        ),
      );
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  final String title;
  final String subtitle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : const Color(0xFF9E9E9E);
    final iconColor = isDark
        ? AppColors.surfaceDarkElevated
        : const Color(0xFFE0D0C0);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 72, color: iconColor)
                .animate()
                .scale(begin: const Offset(0.8, 0.8), duration: 350.ms),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: GoogleFonts.dmSans(fontSize: 13, color: textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
