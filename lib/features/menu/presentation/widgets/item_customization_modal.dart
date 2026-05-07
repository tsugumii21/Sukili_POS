import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/isar_collections/menu_item_collection.dart';
import '../../../orders/domain/entities/cart_item.dart';
import '../../../orders/presentation/providers/order_provider.dart';

/// Parsed variant from the item's variantsJson (legacy flat format).
class _Variant {
  final String name;
  final double priceDelta;

  const _Variant({required this.name, required this.priceDelta});
}

/// Parsed variant group from the item's variantGroupsJson (new format).
class _VariantGroup {
  final String groupName;
  final List<_Variant> options;

  const _VariantGroup({required this.groupName, required this.options});
}

/// Parsed modifier from the item's modifiersJson.
class _Modifier {
  final String groupName;
  final String name;
  final double priceDelta;

  const _Modifier({
    required this.groupName,
    required this.name,
    required this.priceDelta,
  });
}

/// ItemCustomizationModal — A premium DraggableScrollableSheet for customizing
/// a menu item before adding it to the cart.
///
/// Features:
/// - Variant selection (ChoiceChip row)
/// - Modifier toggles grouped by category (CheckboxListTile)
/// - Quantity picker (min 1)
/// - Special instructions text field
/// - "Update" mode when the item is already in the cart
class ItemCustomizationModal extends ConsumerStatefulWidget {
  const ItemCustomizationModal({
    super.key,
    required this.item,
    this.existingCartItem,
  });

  final MenuItemCollection item;

  /// If provided, the modal opens in "Update" mode pre-filled with existing selections.
  final CartItem? existingCartItem;

  /// Static helper to show the modal from anywhere.
  static void show(
    BuildContext context, {
    required MenuItemCollection item,
    CartItem? existingCartItem,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ItemCustomizationModal(
        item: item,
        existingCartItem: existingCartItem,
      ),
    );
  }

  @override
  ConsumerState<ItemCustomizationModal> createState() =>
      _ItemCustomizationModalState();
}

class _ItemCustomizationModalState
    extends ConsumerState<ItemCustomizationModal> {
  // Legacy flat variants (used when variantGroupsJson is empty)
  late List<_Variant> _variants;
  // New multi-group variants
  late List<_VariantGroup> _variantGroups;
  /// One selected index per group (for new format).
  late List<int> _selectedGroupIndices;

  late List<_Modifier> _allModifiers;
  late Map<String, List<_Modifier>> _modifierGroups;

  // Legacy: single selected index
  int _selectedVariantIndex = 0;
  final Set<int> _selectedModifierIndices = {};
  int _quantity = 1;
  final _notesController = TextEditingController();

  bool get _isUpdateMode => widget.existingCartItem != null;
  bool get _useGroups => _variantGroups.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _parseItemData();
    _prefillIfUpdating();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _parseItemData() {
    // ── New multi-group format ────────────────────────────────────────
    _variantGroups = widget.item.variantGroupsJson
        .map((json) {
          try {
            final map = jsonDecode(json) as Map<String, dynamic>;
            final options = (map['options'] as List<dynamic>?)
                    ?.map((o) {
                      final om = o as Map<String, dynamic>;
                      return _Variant(
                        name: om['name'] as String? ?? '',
                        priceDelta:
                            (om['priceDelta'] as num?)?.toDouble() ?? 0,
                      );
                    })
                    .toList() ??
                [];
            return _VariantGroup(
              groupName: map['groupName'] as String? ?? '',
              options: options,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<_VariantGroup>()
        .toList();
    // Default: first option selected for each group
    _selectedGroupIndices = List.filled(_variantGroups.length, 0);

    // ── Legacy flat variants (fallback) ──────────────────────────────
    _variants = widget.item.variantsJson
        .map((json) {
          try {
            final map = jsonDecode(json) as Map<String, dynamic>;
            return _Variant(
              name: map['name'] as String? ?? 'Default',
              priceDelta: (map['priceDelta'] as num?)?.toDouble() ?? 0,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<_Variant>()
        .toList();

    // ── Modifiers ────────────────────────────────────────────────────
    _allModifiers = widget.item.modifiersJson
        .map((json) {
          try {
            final map = jsonDecode(json) as Map<String, dynamic>;
            return _Modifier(
              groupName: map['groupName'] as String? ?? 'Extras',
              name: map['name'] as String? ?? '',
              priceDelta: (map['priceDelta'] as num?)?.toDouble() ?? 0,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<_Modifier>()
        .toList();

    _modifierGroups = {};
    for (final mod in _allModifiers) {
      _modifierGroups.putIfAbsent(mod.groupName, () => []).add(mod);
    }
  }

  void _prefillIfUpdating() {
    final existing = widget.existingCartItem;
    if (existing == null) return;

    _quantity = existing.quantity;
    _notesController.text = existing.notes ?? '';

    if (_useGroups) {
      // Restore group selections by matching variant name across all groups
      if (existing.variantName != null) {
        for (int gi = 0; gi < _variantGroups.length; gi++) {
          final idx = _variantGroups[gi]
              .options
              .indexWhere((o) => o.name == existing.variantName);
          if (idx != -1) _selectedGroupIndices[gi] = idx;
        }
      }
    } else {
      // Legacy restore
      if (existing.variantName != null && _variants.isNotEmpty) {
        final idx =
            _variants.indexWhere((v) => v.name == existing.variantName);
        if (idx != -1) _selectedVariantIndex = idx;
      }
    }

    // Restore modifier selections
    for (int i = 0; i < _allModifiers.length; i++) {
      if (existing.modifiers.contains(_allModifiers[i].name)) {
        _selectedModifierIndices.add(i);
      }
    }
  }

  /// Calculates the running total: (base + variant deltas + modifier deltas) × quantity.
  double get _runningTotal => _unitPrice * _quantity;

  /// The unit price (before quantity multiplication).
  double get _unitPrice {
    double price = widget.item.basePrice;
    if (_useGroups) {
      for (int gi = 0; gi < _variantGroups.length; gi++) {
        final g = _variantGroups[gi];
        final selIdx = gi < _selectedGroupIndices.length
            ? _selectedGroupIndices[gi]
            : 0;
        if (selIdx < g.options.length) {
          price += g.options[selIdx].priceDelta;
        }
      }
    } else if (_variants.isNotEmpty) {
      price += _variants[_selectedVariantIndex].priceDelta;
    }
    for (final idx in _selectedModifierIndices) {
      price += _allModifiers[idx].priceDelta;
    }
    return price;
  }

  /// Returns a human-readable variant description for cart display.
  /// e.g. "Large / Iced" for multi-group, "Large" for legacy.
  String? get _selectedVariantLabel {
    if (_useGroups) {
      final parts = <String>[];
      for (int gi = 0; gi < _variantGroups.length; gi++) {
        final g = _variantGroups[gi];
        final selIdx = gi < _selectedGroupIndices.length
            ? _selectedGroupIndices[gi]
            : 0;
        if (selIdx < g.options.length) {
          parts.add(g.options[selIdx].name);
        }
      }
      return parts.isEmpty ? null : parts.join(' / ');
    } else {
      return _variants.isNotEmpty
          ? _variants[_selectedVariantIndex].name
          : null;
    }
  }

  void _addOrUpdateCart() {
    final variantName = _selectedVariantLabel;

    final selectedModNames = _selectedModifierIndices
        .map((i) => _allModifiers[i].name)
        .toList();

    final cartItem = CartItem(
      itemSyncId: widget.item.syncId,
      itemName: widget.item.name,
      variantName: variantName,
      unitPrice: _unitPrice,
      quantity: _quantity,
      modifiers: selectedModNames,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    final notifier = ref.read(orderProvider.notifier);

    if (_isUpdateMode) {
      // Remove the old entry, then add the updated one
      notifier.removeItem(widget.existingCartItem!.cartKey);
    }
    notifier.addItem(cartItem);

    Navigator.pop(context);

    // Brief success feedback
    final label = _isUpdateMode ? 'updated' : 'added';
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        backgroundColor: const Color(0xFF8B4049),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${widget.item.name}${variantName != null ? " ($variantName)" : ""} $label!',
                style: GoogleFonts.dmSans(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.surfaceDark : AppColors.white;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final chipBg = isDark ? AppColors.cardDark : AppColors.backgroundLight;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // ── Scrollable Content ────────────────────────────────────
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: textPrimary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),

                    // ── Image Header ────────────────────────────────────
                    if (widget.item.imageUrl != null &&
                        widget.item.imageUrl!.isNotEmpty)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(28)),
                            child: Image.network(
                              widget.item.imageUrl!,
                              width: double.infinity,
                              height: 160,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildImagePlaceholder(isDark),
                            ),
                          ),
                          // Gradient overlay at bottom of image
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    sheetBg,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      _buildImagePlaceholder(isDark),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Item Name ─────────────────────────────────
                          Text(
                            widget.item.name,
                            style: GoogleFonts.dmSans(
                              color: textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ).animate().fadeIn(duration: 300.ms),

                          if (widget.item.description != null &&
                              widget.item.description!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              widget.item.description!,
                              style: GoogleFonts.dmSans(
                                color:
                                    textPrimary.withValues(alpha: 0.5),
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          // ── Variant Selection (new multi-group) ───────
                          if (_useGroups) ...[
                            ..._variantGroups
                                .asMap()
                                .entries
                                .map((entry) {
                              final gi = entry.key;
                              final group = entry.value;
                              return Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    group.groupName.toUpperCase(),
                                    style: GoogleFonts.dmSans(
                                      color: textPrimary
                                          .withValues(alpha: 0.4),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: List.generate(
                                        group.options.length, (oi) {
                                      final opt = group.options[oi];
                                      final isSelected =
                                          _selectedGroupIndices[gi] == oi;
                                      final price =
                                          widget.item.basePrice +
                                              opt.priceDelta;
                                      return Expanded(
                                        child: GestureDetector(
                                          onTap: () => setState(() =>
                                              _selectedGroupIndices[gi] =
                                                  oi),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            margin: EdgeInsets.only(
                                                right: oi <
                                                        group.options
                                                                .length -
                                                            1
                                                    ? 10
                                                    : 0),
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 14),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? const Color(
                                                      0xFF8B4049)
                                                  : chipBg,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      14),
                                              border: isSelected
                                                  ? null
                                                  : Border.all(
                                                      color: Colors.black
                                                          .withValues(
                                                              alpha:
                                                                  0.06)),
                                              boxShadow: isSelected
                                                  ? [
                                                      BoxShadow(
                                                        color: const Color(
                                                                0xFF8B4049)
                                                            .withValues(
                                                                alpha:
                                                                    0.25),
                                                        blurRadius: 8,
                                                        offset:
                                                            const Offset(
                                                                0, 3),
                                                      )
                                                    ]
                                                  : null,
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  opt.name,
                                                  style:
                                                      GoogleFonts.dmSans(
                                                    color: isSelected
                                                        ? AppColors.white
                                                        : textPrimary,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w700,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  opt.priceDelta == 0
                                                      ? CurrencyFormatter
                                                          .format(price)
                                                      : '+${CurrencyFormatter.format(opt.priceDelta)}',
                                                  style:
                                                      GoogleFonts.dmSans(
                                                    color: isSelected
                                                        ? AppColors.white
                                                            .withValues(
                                                                alpha: 0.7)
                                                        : textPrimary
                                                            .withValues(
                                                                alpha: 0.5),
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              );
                            }),
                          ]

                          // ── Legacy single variant row ─────────────────
                          else if (_variants.isNotEmpty) ...[
                            Text(
                              'SIZE',
                              style: GoogleFonts.dmSans(
                                color:
                                    textPrimary.withValues(alpha: 0.4),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: List.generate(
                                  _variants.length, (i) {
                                final v = _variants[i];
                                final isSelected =
                                    i == _selectedVariantIndex;
                                final price = widget.item.basePrice +
                                    v.priceDelta;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() =>
                                        _selectedVariantIndex = i),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 200),
                                      margin: EdgeInsets.only(
                                          right: i <
                                                  _variants.length - 1
                                              ? 10
                                              : 0),
                                      padding:
                                          const EdgeInsets.symmetric(
                                              vertical: 14),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF8B4049)
                                            : chipBg,
                                        borderRadius:
                                            BorderRadius.circular(14),
                                        border: isSelected
                                            ? null
                                            : Border.all(
                                                color: Colors.black
                                                    .withValues(
                                                        alpha: 0.06)),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: const Color(
                                                          0xFF8B4049)
                                                      .withValues(
                                                          alpha: 0.25),
                                                  blurRadius: 8,
                                                  offset:
                                                      const Offset(
                                                          0, 3),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            v.name,
                                            style: GoogleFonts.dmSans(
                                              color: isSelected
                                                  ? AppColors.white
                                                  : textPrimary,
                                              fontSize: 14,
                                              fontWeight:
                                                  FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            CurrencyFormatter.format(
                                                price),
                                            style: GoogleFonts.dmSans(
                                              color: isSelected
                                                  ? AppColors.white
                                                      .withValues(
                                                          alpha: 0.7)
                                                  : textPrimary
                                                      .withValues(
                                                          alpha: 0.5),
                                              fontSize: 12,
                                              fontWeight:
                                                  FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 28),
                          ],

                          // ── Modifier Groups ───────────────────────────
                          if (_modifierGroups.isNotEmpty)
                            ..._modifierGroups.entries.map(
                                (entry) => _buildModifierGroup(
                                      entry.key,
                                      entry.value,
                                      textPrimary,
                                      chipBg,
                                      isDark,
                                    )),

                          // ── Quantity ───────────────────────────────────
                          Text(
                            'QUANTITY',
                            style: GoogleFonts.dmSans(
                              color:
                                  textPrimary.withValues(alpha: 0.4),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: chipBg,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: _quantity > 1
                                      ? () => setState(
                                          () => _quantity--)
                                      : null,
                                  icon: Icon(
                                    Icons.remove_rounded,
                                    color: _quantity > 1
                                        ? const Color(0xFF8B4049)
                                        : textPrimary.withValues(
                                            alpha: 0.2),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Text(
                                    '$_quantity',
                                    style:
                                        GoogleFonts.dmSans(
                                      color: textPrimary,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      setState(() => _quantity++),
                                  icon: const Icon(
                                    Icons.add_rounded,
                                    color: Color(0xFF8B4049),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // ── Notes ─────────────────────────────────────
                          Text(
                            'SPECIAL INSTRUCTIONS',
                            style: GoogleFonts.dmSans(
                              color:
                                  textPrimary.withValues(alpha: 0.4),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _notesController,
                            maxLines: 2,
                            style: GoogleFonts.dmSans(
                              color: textPrimary,
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g. No onions, extra sauce',
                              hintStyle: GoogleFonts.dmSans(
                                color: textPrimary.withValues(
                                    alpha: 0.3),
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: chipBg,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding:
                                  const EdgeInsets.all(16),
                            ),
                          ),

                          // Extra bottom padding so content doesn't sit behind sticky bar
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Sticky Bottom Bar ────────────────────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: sheetBg,
                  border: Border(
                    top: BorderSide(
                      color: textPrimary.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      // Running total
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total',
                            style: GoogleFonts.dmSans(
                              color:
                                  textPrimary.withValues(alpha: 0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(_runningTotal),
                            style: GoogleFonts.dmSans(
                              color: const Color(0xFF8B4049),
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      // Add / Update button
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _addOrUpdateCart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF8B4049),
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(18),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isUpdateMode
                                      ? Icons.edit_rounded
                                      : Icons
                                          .add_shopping_cart_rounded,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _isUpdateMode
                                      ? 'Update Cart'
                                      : 'Add to Cart',
                                  style:
                                      GoogleFonts.dmSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds a grouped section of modifier checkboxes.
  Widget _buildModifierGroup(
    String groupName,
    List<_Modifier> modifiers,
    Color textPrimary,
    Color chipBg,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          groupName.toUpperCase(),
          style: GoogleFonts.dmSans(
            color: textPrimary.withValues(alpha: 0.4),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        ...modifiers.map((mod) {
          final globalIndex = _allModifiers.indexOf(mod);
          final isChecked =
              _selectedModifierIndices.contains(globalIndex);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isChecked
                  ? const Color(0xFF8B4049).withValues(alpha: 0.08)
                  : chipBg,
              borderRadius: BorderRadius.circular(14),
              border: isChecked
                  ? Border.all(
                      color: const Color(0xFF8B4049)
                          .withValues(alpha: 0.2))
                  : Border.all(
                      color: Colors.black.withValues(alpha: 0.04)),
            ),
            child: CheckboxListTile(
              value: isChecked,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _selectedModifierIndices.add(globalIndex);
                  } else {
                    _selectedModifierIndices.remove(globalIndex);
                  }
                });
              },
              title: Text(
                mod.name,
                style: GoogleFonts.dmSans(
                  color: textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              secondary: Text(
                '+${CurrencyFormatter.format(mod.priceDelta)}',
                style: GoogleFonts.dmSans(
                  color: const Color(0xFF8B4049),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              activeColor: const Color(0xFF8B4049),
              checkboxShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          );
        }),
        const SizedBox(height: 20),
      ],
    );
  }

  /// Placeholder when no item image is available.
  Widget _buildImagePlaceholder(bool isDark) {
    return Container(
      width: double.infinity,
      height: 120,
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant_menu_rounded,
          size: 48,
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.08),
        ),
      ),
    );
  }
}
