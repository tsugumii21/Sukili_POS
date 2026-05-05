import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../providers/order_history_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OrderFilterSheet — bottom sheet for date range + payment + status filters
// ─────────────────────────────────────────────────────────────────────────────

class OrderFilterSheet extends StatefulWidget {
  const OrderFilterSheet({super.key, required this.initial});

  final OrderFilter initial;

  /// Opens the sheet and returns the chosen [OrderFilter] (or null if dismissed).
  static Future<OrderFilter?> show(
    BuildContext context,
    OrderFilter current,
  ) {
    return showModalBottomSheet<OrderFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OrderFilterSheet(initial: current),
    );
  }

  @override
  State<OrderFilterSheet> createState() => _OrderFilterSheetState();
}

class _OrderFilterSheetState extends State<OrderFilterSheet> {
  late DateTime? _startDate;
  late DateTime? _endDate;
  late String? _paymentMethod;
  late String? _status;

  static final _dateFmt = DateFormat('MMM dd, yyyy');

  // Filter options
  static const _paymentOptions = [
    (null, 'All'),
    ('cash', 'Cash'),
    ('gcash', 'GCash'),
    ('other', 'Other'),
  ];

  static const _statusOptions = [
    (null, 'All'),
    ('completed', 'Completed'),
    ('voided', 'Voided'),
    ('refunded', 'Refunded'),
  ];

  @override
  void initState() {
    super.initState();
    _startDate = widget.initial.startDate;
    _endDate = widget.initial.endDate;
    _paymentMethod = widget.initial.paymentMethod;
    _status = widget.initial.status;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF2A1215) : const Color(0xFFFAF6F1);
    final cardBg =
        isDark ? const Color(0xFF3E2723) : const Color(0xFFF9F5F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary =
        isDark ? Colors.white70 : const Color(0xFF6B6B6B);
    const maroon = Color(0xFF8B4049);

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: textSecondary.withAlpha(80),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),

                // Title
                Text(
                  'Filter Orders',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Date Range ───────────────────────────────────────────
                _SectionLabel(
                    label: 'Date Range', textSecondary: textSecondary),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _DateButton(
                        label: _startDate != null
                            ? _dateFmt.format(_startDate!)
                            : 'Start Date',
                        icon: Icons.calendar_today_rounded,
                        onTap: () => _pickDate(isStart: true),
                        hasValue: _startDate != null,
                        cardBg: cardBg,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        maroon: maroon,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('–',
                          style: GoogleFonts.dmSans(
                              fontSize: 16, color: textSecondary)),
                    ),
                    Expanded(
                      child: _DateButton(
                        label: _endDate != null
                            ? _dateFmt.format(_endDate!)
                            : 'End Date',
                        icon: Icons.event_rounded,
                        onTap: () => _pickDate(isStart: false),
                        hasValue: _endDate != null,
                        cardBg: cardBg,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        maroon: maroon,
                      ),
                    ),
                  ],
                ),
                if (_startDate != null || _endDate != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () =>
                        setState(() { _startDate = null; _endDate = null; }),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close_rounded,
                            size: 14, color: textSecondary),
                        const SizedBox(width: 4),
                        Text('Clear dates',
                            style: GoogleFonts.dmSans(
                                fontSize: 12, color: textSecondary)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // ── Payment Method ────────────────────────────────────────
                _SectionLabel(
                    label: 'Payment Method',
                    textSecondary: textSecondary),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _paymentOptions.map((opt) {
                    final value = opt.$1;
                    final label = opt.$2;
                    final isSelected = _paymentMethod == value;
                    return _FilterChip(
                      label: label,
                      isSelected: isSelected,
                      onTap: () =>
                          setState(() => _paymentMethod = value),
                      maroon: maroon,
                      cardBg: cardBg,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // ── Status ────────────────────────────────────────────────
                _SectionLabel(
                    label: 'Order Status', textSecondary: textSecondary),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _statusOptions.map((opt) {
                    final value = opt.$1;
                    final label = opt.$2;
                    final isSelected = _status == value;
                    return _FilterChip(
                      label: label,
                      isSelected: isSelected,
                      onTap: () => setState(() => _status = value),
                      maroon: maroon,
                      cardBg: cardBg,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),

                // ── Action buttons ────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _clearAll,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: maroon,
                          side: const BorderSide(color: maroon),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Clear All',
                          style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _applyFilter,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: maroon,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Apply Filter',
                          style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B4049),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        // Ensure end date is not before start date
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
      } else {
        _endDate = picked;
        // Ensure start date is not after end date
        if (_startDate != null && _startDate!.isAfter(picked)) {
          _startDate = picked;
        }
      }
    });
  }

  void _clearAll() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _paymentMethod = null;
      _status = null;
    });
  }

  void _applyFilter() {
    Navigator.of(context).pop(
      OrderFilter(
        searchQuery: widget.initial.searchQuery,
        paymentMethod: _paymentMethod,
        status: _status,
        startDate: _startDate,
        endDate: _endDate,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.textSecondary});

  final String label;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.hasValue,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.maroon,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool hasValue;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color maroon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(10),
          border: hasValue
              ? Border.all(color: maroon.withAlpha(180), width: 1.2)
              : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 16, color: hasValue ? maroon : textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: hasValue ? textPrimary : textSecondary,
                  fontWeight:
                      hasValue ? FontWeight.w600 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.maroon,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color maroon;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? maroon.withAlpha(25) : cardBg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? maroon : textSecondary.withAlpha(80),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? maroon : textSecondary,
          ),
        ),
      ),
    );
  }
}
