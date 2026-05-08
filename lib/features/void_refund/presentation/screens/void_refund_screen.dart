import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';import 'package:go_router/go_router.dart';import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/isar_collections/order_collection.dart';
import '../providers/void_refund_provider.dart';
import '../widgets/admin_pin_dialog.dart';
import '../widgets/refund_sheet.dart';
import '../../../../shared/widgets/app_card.dart';

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
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final border = isDark ? AppColors.borderDark : AppColors.primaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    // Show error snackbar if present
    ref.listen<VoidRefundState>(voidRefundProvider, (_, next) {
      if (next.errorMessage != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!,
                style: AppTextStyles.bodySemiBold(context).copyWith(color: Colors.white)),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Voids & Refunds',
          style: AppTextStyles.h3(context),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border(bottom: BorderSide(color: border.withValues(alpha: 0.5), width: 1)),
            ),
            child: TabBar(
              controller: _tabCtrl,
              tabs: _tabs,
              labelStyle: AppTextStyles.bodySemiBold(context).copyWith(color: textPrimary),
              unselectedLabelStyle: AppTextStyles.body(context).copyWith(color: textSecondary),
              labelColor: textPrimary,
              unselectedLabelColor: textSecondary,
              indicatorColor: accent,
              indicatorWeight: 3.0,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
            ),
          ),
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
                        style: AppTextStyles.captionMedium(context).copyWith(
                          color: maroon,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final error = isDark ? AppColors.errorDark : AppColors.errorLight;
    final warning = isDark ? AppColors.warningDark : AppColors.warningLight;
    final borderCol = isDark ? AppColors.borderDark : AppColors.primaryLight;
    
    Color actionColor;
    if (mode == _TabMode.history) {
      actionColor = order.status.toLowerCase() == 'voided' ? error : warning;
      if (order.status.toLowerCase() == 'completed') {
        actionColor = AppColors.successLight;
      }
    } else {
      actionColor = mode == _TabMode.voidOrder ? error : warning;
    }

    return AppCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent border
            Container(
              width: 3,
              decoration: BoxDecoration(
                color: mode == _TabMode.history 
                    ? actionColor 
                    : error,
                borderRadius: const BorderRadius.horizontal(left: AppRadius.small),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    // Order info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            order.orderNumber,
                            style: AppTextStyles.bodySemiBold(context).copyWith(color: textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${order.cashierName}  ·  ${_timeFmt.format(order.orderedAt)}',
                            style: AppTextStyles.captionSecondary(context),
                          ),
                        ],
                      ),
                    ),
                    // Total + action
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          CurrencyFormatter.format(order.totalAmount),
                          style: AppTextStyles.bodyMedium(context).copyWith(color: accent),
                        ),
                        const SizedBox(height: 4),
                        _buildActionButton(context, ref, actionColor),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref, Color actionColor) {
    if (mode == _TabMode.history) {
      return Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: actionColor.withValues(alpha: 0.12),
          borderRadius: AppRadius.pillBR,
          border: Border.all(color: actionColor.withValues(alpha: 0.4)),
        ),
        child: Text(
          _capitalize(order.status),
          style: AppTextStyles.captionMedium(context).copyWith(color: actionColor),
        ),
      );
    }

    final isVoid = mode == _TabMode.voidOrder;
    final label = isVoid ? 'Void' : 'Refund';

    return GestureDetector(
      onTap: () => isVoid ? _handleVoid(context, ref) : _handleRefund(context, ref),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: actionColor.withValues(alpha: 0.12),
          borderRadius: AppRadius.pillBR,
          border: Border.all(color: actionColor.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: AppTextStyles.captionMedium(context).copyWith(color: actionColor),
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
            style: AppTextStyles.bodySemiBold(context).copyWith(color: Colors.white),
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
            style: AppTextStyles.h3(context),
          ),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            maxLines: 3,
            style: AppTextStyles.body(context),
            decoration: InputDecoration(
              hintText: 'Enter void reason (required)',
              hintStyle: AppTextStyles.body(context).copyWith(
                  color: textSecondary),
              filled: true,
              fillColor: isDark
                  ? AppColors.cardDark
                  : AppColors.cardLight,
              border: OutlineInputBorder(
                borderRadius: AppRadius.mediumBR,
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.md),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(null),
              child: Text('Cancel',
                  style: AppTextStyles.bodySemiBold(context).copyWith(color: textSecondary)),
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
                  style: AppTextStyles.bodySemiBold(context).copyWith(color: Colors.white)),
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
            style: AppTextStyles.bodySemiBold(context).copyWith(color: Colors.white),
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
              style: AppTextStyles.bodySemiBold(context).copyWith(
                color: textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: AppTextStyles.captionMedium(context).copyWith(color: textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
