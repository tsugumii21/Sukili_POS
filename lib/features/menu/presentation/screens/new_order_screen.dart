
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/isar_collections/menu_item_collection.dart';
import '../../../orders/presentation/providers/order_provider.dart';
import '../providers/menu_provider.dart';
import '../widgets/category_pill.dart';
import '../widgets/item_card.dart';
import '../widgets/item_customization_modal.dart';

/// NewOrderScreen — The heart of the POS.
/// Category filters → searchable item grid → item customization → cart FAB.
class NewOrderScreen extends ConsumerStatefulWidget {
  const NewOrderScreen({super.key});

  @override
  ConsumerState<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends ConsumerState<NewOrderScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuState = ref.watch(menuProvider);
    final orderState = ref.watch(orderProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 22),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteConstants.cashierHome);
            }
          },
        ),
        title: Text(
          'New Order',
          style: GoogleFonts.plusJakartaSans(
            color: textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        actions: [
          // Cart badge icon
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart_outlined, color: textPrimary, size: 26),
                onPressed: orderState.isNotEmpty
                    ? () => _showCartSheet(context)
                    : null,
              ),
              if (orderState.isNotEmpty)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF8B4049),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      orderState.itemCount.toString(),
                      style: GoogleFonts.inter(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── Search Bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.white,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => ref.read(menuProvider.notifier).updateSearch(v),
                style: GoogleFonts.inter(color: textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Search items...',
                  hintStyle: GoogleFonts.inter(
                    color: textPrimary.withValues(alpha: 0.35),
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: textPrimary.withValues(alpha: 0.35),
                    size: 22,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close_rounded, color: textPrimary.withValues(alpha: 0.35), size: 20),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(menuProvider.notifier).updateSearch('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: AppSpacing.md),

          // ── Category Pills ──────────────────────────────────────────────
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              children: [
                CategoryPill(
                  label: 'All',
                  emoji: '🍽️',
                  isSelected: menuState.selectedCategoryId == null,
                  onTap: () => ref.read(menuProvider.notifier).selectCategory(null),
                ),
                const SizedBox(width: 10),
                ...menuState.categories.map((cat) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: CategoryPill(
                        label: cat.name,
                        emoji: cat.iconEmoji,
                        isSelected: menuState.selectedCategoryId == cat.syncId,
                        onTap: () => ref.read(menuProvider.notifier).selectCategory(cat.syncId),
                      ),
                    )),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

          const SizedBox(height: AppSpacing.md),

          // ── Item Grid ───────────────────────────────────────────────────
          Expanded(
            child: menuState.isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : menuState.items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off_rounded, size: 48, color: textPrimary.withValues(alpha: 0.2)),
                            const SizedBox(height: 12),
                            Text(
                              'No items found',
                              style: GoogleFonts.inter(
                                color: textPrimary.withValues(alpha: 0.4),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: menuState.items.length,
                        itemBuilder: (context, index) {
                          final item = menuState.items[index];
                          return ItemCard(
                            item: item,
                            onTap: () => _showItemCustomization(context, item),
                          ).animate().fadeIn(
                                duration: 400.ms,
                                delay: (50 * index).ms,
                              );
                        },
                      ),
          ),
        ],
      ),

      // ── Cart FAB ──────────────────────────────────────────────────────
      floatingActionButton: orderState.isNotEmpty
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              width: double.infinity,
              height: 60,
              child: FloatingActionButton.extended(
                backgroundColor: const Color(0xFF8B4049),
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                onPressed: () => context.push(RouteConstants.checkout),
                icon: const Icon(Icons.shopping_cart_checkout_rounded, color: AppColors.white),
                label: Text(
                  'Checkout  •  ${CurrencyFormatter.format(orderState.total)}',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.5, end: 0, duration: 300.ms, curve: Curves.easeOut)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ── Item Customization ──────────────────────────────────────────────────
  void _showItemCustomization(BuildContext context, MenuItemCollection item) {
    ItemCustomizationModal.show(context, item: item);
  }

  // ── Cart Preview Sheet ──────────────────────────────────────────────────
  void _showCartSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.surfaceDark : AppColors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final order = ref.watch(orderProvider);
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: textPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Order',
                        style: GoogleFonts.plusJakartaSans(
                          color: textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(orderProvider.notifier).clearCart();
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Clear All',
                          style: GoogleFonts.inter(
                            color: AppColors.errorLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: order.items.length,
                      itemBuilder: (context, index) {
                        final cartItem = order.items[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cartItem.itemName,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (cartItem.variantName != null)
                                      Text(
                                        cartItem.variantName!,
                                        style: GoogleFonts.inter(
                                          color: textPrimary.withValues(alpha: 0.5),
                                          fontSize: 12,
                                        ),
                                      ),
                                    Text(
                                      CurrencyFormatter.format(cartItem.subtotal),
                                      style: GoogleFonts.plusJakartaSans(
                                        color: const Color(0xFF8B4049),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Quantity controls
                              Row(
                                children: [
                                  _QtyButton(
                                    icon: Icons.remove_rounded,
                                    onTap: () => ref.read(orderProvider.notifier)
                                        .updateQuantity(cartItem.cartKey, cartItem.quantity - 1),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    child: Text(
                                      cartItem.quantity.toString(),
                                      style: GoogleFonts.plusJakartaSans(
                                        color: textPrimary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  _QtyButton(
                                    icon: Icons.add_rounded,
                                    onTap: () => ref.read(orderProvider.notifier)
                                        .updateQuantity(cartItem.cartKey, cartItem.quantity + 1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Checkout button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        this.context.mounted
                            ? GoRouter.of(this.context).push(RouteConstants.checkout)
                            : null;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B4049),
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Checkout  •  ${CurrencyFormatter.format(order.total)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Small +/- button used in the cart quantity controls.
class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF8B4049)),
      ),
    );
  }
}
