import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_constants.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/app_card.dart';
import '../providers/reports_provider.dart';
import '../widgets/export_sheet.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isRangeMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateReportData());
  }

  // ── Date helpers ───────────────────────────────────────────────────────

  String _getDateLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(_startDate.year, _startDate.month, _startDate.day);

    if (!_isRangeMode) {
      final diff = today.difference(start).inDays;
      if (diff == 0) return 'Today';
      if (diff == 1) return 'Yesterday';
      if (diff <= 6) return '$diff days ago';
      return DateFormat('MMM d, y').format(_startDate);
    } else {
      if (_endDate == null) return DateFormat('MMM d, y').format(_startDate);
      final startStr = DateFormat('MMM d').format(_startDate);
      final endStr = DateFormat('MMM d, y').format(_endDate!);
      return '$startStr – $endStr';
    }
  }

  bool _isToday() {
    final now = DateTime.now();
    return _startDate.year == now.year &&
        _startDate.month == now.month &&
        _startDate.day == now.day &&
        _endDate == null;
  }

  DateTimeRange _getDateRange() {
    final start = DateTime(_startDate.year, _startDate.month, _startDate.day);
    if (!_isRangeMode || _endDate == null) {
      return DateTimeRange(
          start: start, end: start.add(const Duration(days: 1)));
    }
    final end =
        DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
    return DateTimeRange(start: start, end: end);
  }

  void _updateReportData() {
    final range = _getDateRange();
    ref.read(reportsProvider.notifier).setPeriod(
          _isRangeMode ? ReportPeriod.custom : ReportPeriod.day,
          customStart: range.start,
          customEnd: range.end,
        );
  }

  Future<void> _openDatePicker() async {
    if (_isRangeMode) {
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2024, 1, 1),
        lastDate: DateTime.now(),
        initialDateRange: DateTimeRange(
          start: _startDate,
          end: _endDate ?? _startDate,
        ),
        helpText: 'SELECT DATE RANGE',
        cancelText: 'Cancel',
        confirmText: 'Apply',
      );
      if (picked != null) {
        setState(() {
          _startDate = picked.start;
          _endDate = picked.end;
        });
        _updateReportData();
      }
    } else {
      final picked = await showDatePicker(
        context: context,
        initialDate: _startDate,
        firstDate: DateTime(2024, 1, 1),
        lastDate: DateTime.now(),
        helpText: 'SELECT DATE',
        cancelText: 'Cancel',
        confirmText: 'Apply',
      );
      if (picked != null) {
        setState(() {
          _startDate = picked;
          _endDate = null;
        });
        _updateReportData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Reports', style: AppTextStyles.h3(context)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteConstants.adminHome);
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.upload_rounded, color: accent),
            onPressed: () => ExportSheet.show(context, state),
            tooltip: 'Export',
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date selector bar
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    // Mode toggle
                    _ModeToggle(
                      isRangeMode: _isRangeMode,
                      onToggle: (val) => setState(() {
                        _isRangeMode = val;
                        _endDate = null;
                        _updateReportData();
                      }),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Date display button
                    Expanded(
                      child: GestureDetector(
                        onTap: _openDatePicker,
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.cardDark
                                : AppColors.cardLight,
                            borderRadius: AppRadius.mediumBR,
                            border: Border.all(
                              color: accent.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded,
                                  size: 16, color: accent),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  _getDateLabel(),
                                  style: AppTextStyles.bodyMedium(context)
                                      .copyWith(color: accent),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              Icon(Icons.arrow_drop_down_rounded,
                                  color: textSecondary),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Reset-to-today button
                    if (!_isToday())
                      Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.xs),
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _startDate = DateTime.now();
                            _endDate = null;
                            _isRangeMode = false;
                            _updateReportData();
                          }),
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.cardDark
                                  : AppColors.cardLight,
                              borderRadius: AppRadius.mediumBR,
                            ),
                            child: Icon(Icons.today_rounded,
                                size: 18, color: textSecondary),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // KPI grid
              _KpiGrid(state: state),
              const SizedBox(height: AppSpacing.md),

              // Revenue chart
              _RevenueChart(state: state),
              const SizedBox(height: AppSpacing.md),

              // Payment donut
              _PaymentDonutChart(state: state),
              const SizedBox(height: AppSpacing.md),

              // Top items bar chart
              _TopItemsChart(state: state),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mode Toggle — 1 Day | Range
// ─────────────────────────────────────────────────────────────────────────────

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.isRangeMode,
    required this.onToggle,
  });

  final bool isRangeMode;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.mediumBR,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleOption(
            label: '1 Day',
            icon: Icons.today_rounded,
            isSelected: !isRangeMode,
            onTap: () => onToggle(false),
          ),
          _ToggleOption(
            label: 'Range',
            icon: Icons.date_range_rounded,
            isSelected: isRangeMode,
            onTap: () => onToggle(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDuration.fast,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? accent : Colors.transparent,
          borderRadius: AppRadius.mediumBR,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14, color: isSelected ? Colors.white : textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.captionMedium(context).copyWith(
                color: isSelected ? Colors.white : textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KPI Grid
// ─────────────────────────────────────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.state});
  final ReportState state;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final highestSale = state.orders.isEmpty
        ? 0.0
        : state.orders
            .map((o) => o.totalAmount)
            .fold(0.0, (max, v) => v > max ? v : max);

    final cards = [
      _KpiCardData(
        icon: Icons.payments_outlined,
        value: CurrencyFormatter.format(state.totalSales),
        label: 'Total Revenue',
        valueStyle: AppTextStyles.priceSmall(context).copyWith(color: accent),
      ),
      _KpiCardData(
        icon: Icons.receipt_long_outlined,
        value: '${state.totalOrders}',
        label: 'Total Orders',
        valueStyle:
            AppTextStyles.priceSmall(context).copyWith(color: textPrimary),
      ),
      _KpiCardData(
        icon: Icons.trending_up_rounded,
        value: CurrencyFormatter.format(state.averageOrderValue),
        label: 'Average Order',
        valueStyle:
            AppTextStyles.priceSmall(context).copyWith(color: textPrimary),
      ),
      _KpiCardData(
        icon: Icons.workspace_premium_rounded,
        value: CurrencyFormatter.format(highestSale),
        label: 'Highest Sale',
        valueStyle: AppTextStyles.priceSmall(context).copyWith(color: accent),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.45,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: cards.asMap().entries.map((e) {
          return _KpiCard(data: e.value).animate().fadeIn(
              duration: 250.ms, delay: Duration(milliseconds: e.key * 60));
        }).toList(),
      ),
    );
  }
}

class _KpiCardData {
  final IconData icon;
  final String value;
  final String label;
  final TextStyle valueStyle;

  const _KpiCardData({
    required this.icon,
    required this.value,
    required this.label,
    required this.valueStyle,
  });
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.data});
  final _KpiCardData data;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: AppRadius.smallBR,
            ),
            child: Icon(data.icon, size: 14, color: accent),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            data.value,
            style: data.valueStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            data.label,
            style: AppTextStyles.caption(context).copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Revenue Line Chart
// ─────────────────────────────────────────────────────────────────────────────

class _RevenueChart extends StatelessWidget {
  const _RevenueChart({required this.state});
  final ReportState state;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Revenue Trend', style: AppTextStyles.h3(context)),
              const Spacer(),
              Text(state.periodLabel,
                  style: AppTextStyles.captionSecondary(context)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 200,
            child: state.orders.isEmpty
                ? Center(
                    child: Text('No data for this period',
                        style: AppTextStyles.captionSecondary(context)),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: textSecondary.withValues(alpha: 0.15),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 48,
                            getTitlesWidget: (value, _) => Text(
                              CurrencyFormatter.formatCompact(value),
                              style: AppTextStyles.caption(context),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) => Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                _formatXLabel(value, state.period),
                                style: AppTextStyles.caption(context),
                              ),
                            ),
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: state.revenueSpots,
                          isCurved: true,
                          curveSmoothness: 0.3,
                          color: accent,
                          barWidth: 2.5,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (_, __, ___, ____) =>
                                FlDotCirclePainter(
                              radius: 3.5,
                              color: accent,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                accent.withValues(alpha: 0.25),
                                accent.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (spots) => spots
                              .map((s) => LineTooltipItem(
                                    CurrencyFormatter.format(s.y),
                                    AppTextStyles.captionMedium(context)
                                        .copyWith(color: Colors.white),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _formatXLabel(double value, ReportPeriod period) {
    final i = value.toInt();
    switch (period) {
      case ReportPeriod.day:
        if (i % 4 != 0) return '';
        return '${i.toString().padLeft(2, '0')}:00';
      case ReportPeriod.week:
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return i < days.length ? days[i] : '';
      case ReportPeriod.month:
        if (i % 5 != 0) return '';
        return '${i + 1}';
      case ReportPeriod.year:
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
        return i < months.length ? months[i] : '';
      case ReportPeriod.custom:
        return '${i + 1}';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment Donut Chart
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentDonutChart extends StatelessWidget {
  const _PaymentDonutChart({required this.state});
  final ReportState state;

  Color _paymentColor(String method, bool isDark) {
    switch (method.toLowerCase()) {
      case 'cash':
        return isDark ? AppColors.accentDark : AppColors.accentLight;
      case 'gcash':
        return isDark ? AppColors.successDark : AppColors.successLight;
      case 'maya':
        return isDark ? AppColors.warningDark : AppColors.warningLight;
      case 'card':
        return isDark ? AppColors.secondaryDark : AppColors.secondaryLight;
      default:
        return isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final breakdown = state.paymentBreakdown;

    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Breakdown', style: AppTextStyles.h3(context)),
          const SizedBox(height: AppSpacing.md),
          if (breakdown.isEmpty)
            SizedBox(
              height: 150,
              child: Center(
                child: Text('No data',
                    style: AppTextStyles.captionSecondary(context)),
              ),
            )
          else
            Row(
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 45,
                      sections: breakdown
                          .map((p) => PieChartSectionData(
                                value: p.percentage,
                                color: _paymentColor(p.method, isDark),
                                radius: 30,
                                showTitle: false,
                              ))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: breakdown.map((p) {
                      final color = _paymentColor(p.method, isDark);
                      final accent =
                          isDark ? AppColors.accentDark : AppColors.accentLight;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(p.methodLabel,
                                style: AppTextStyles.body(context)),
                            const Spacer(),
                            Text(
                              CurrencyFormatter.format(p.amount),
                              style: AppTextStyles.bodyMedium(context)
                                  .copyWith(color: accent),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            SizedBox(
                              width: 42,
                              child: Text(
                                '${p.percentage.toStringAsFixed(1)}%',
                                style: AppTextStyles.captionSecondary(context),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top Items Bar Chart
// ─────────────────────────────────────────────────────────────────────────────

class _TopItemsChart extends StatelessWidget {
  const _TopItemsChart({required this.state});
  final ReportState state;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final topItems = state.topItems;

    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Top Selling Items', style: AppTextStyles.h3(context)),
              const Spacer(),
              Text('by revenue',
                  style: AppTextStyles.captionSecondary(context)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 220,
            child: topItems.isEmpty
                ? Center(
                    child: Text('No data',
                        style: AppTextStyles.captionSecondary(context)),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: topItems.first.revenue * 1.2,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, _, rod, __) {
                            final idx = group.x.toInt();
                            if (idx >= topItems.length) return null;
                            return BarTooltipItem(
                              '${topItems[idx].name}\n${CurrencyFormatter.format(rod.toY)}',
                              AppTextStyles.caption(context)
                                  .copyWith(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              final idx = value.toInt();
                              if (idx >= topItems.length)
                                return const SizedBox();
                              final name = topItems[idx].name;
                              final label = name.length > 8
                                  ? '${name.substring(0, 8)}…'
                                  : name;
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(label,
                                    style: AppTextStyles.caption(context)),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 44,
                            getTitlesWidget: (value, _) => Text(
                              CurrencyFormatter.formatCompact(value),
                              style: AppTextStyles.caption(context),
                            ),
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: textSecondary.withValues(alpha: 0.15),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: topItems.asMap().entries.map((e) {
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.revenue,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  accent,
                                  accent.withValues(alpha: 0.5),
                                ],
                              ),
                              width: 28,
                              borderRadius: const BorderRadius.vertical(
                                  top: AppRadius.small),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
