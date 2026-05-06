import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/isar_collections/user_collection.dart';
import '../providers/auth_provider.dart';
import '../widgets/cashier_card.dart';

/// CashierSelectionScreen — shows a 2-column grid of active cashiers.
/// Redesigned with Plus Jakarta Sans and Inter for a high-end fintech aesthetic.
class CashierSelectionScreen extends ConsumerStatefulWidget {
  const CashierSelectionScreen({super.key});

  @override
  ConsumerState<CashierSelectionScreen> createState() =>
      _CashierSelectionScreenState();
}

class _CashierSelectionScreenState
    extends ConsumerState<CashierSelectionScreen> {
  List<UserCollection> _cashiers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCashiers();
  }

  Future<void> _loadCashiers() async {
    final cashiers = await ref.read(authProvider.notifier).loadCashiers();
    if (mounted) {
      setState(() {
        _cashiers = cashiers;
        _isLoading = false;
      });
    }
  }

  void _onCashierTapped(UserCollection cashier) {
    ref.read(authProvider.notifier).selectCashier(cashier);

    if (cashier.pinHash != null) {
      context.push(RouteConstants.cashierPin);
    } else {
      // No PIN set — go straight in
      ref.read(authProvider.notifier).verifyPin('').then((_) {
        if (mounted) context.go(RouteConstants.cashierHome);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.lg,
              ),
              child: Row(
                children: [
                  // Logo in a modern rounded box
                  Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      'assets/images/sukli_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Sukli',
                    style: GoogleFonts.dmSans(
                      color: textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: AppSpacing.md),

            // ── Title ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select Cashier',
                      style: GoogleFonts.dmSans(
                        color: textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose your profile to start selling',
                    style: GoogleFonts.dmSans(
                      color: textSecondary.withValues(alpha: 0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.05, end: 0),

            const SizedBox(height: AppSpacing.xl),

            // ── Cashier Grid ───────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator.adaptive(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? AppColors.accentDark : AppColors.accentLight,
                        ),
                      ),
                    )
                  : _cashiers.isEmpty
                      ? Center(
                          child: Text(
                            'No active cashiers found.',
                            style: GoogleFonts.dmSans(
                              color: textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.md,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: _cashiers.length,
                          itemBuilder: (context, index) {
                            final cashier = _cashiers[index];
                            return CashierCard(
                              cashier: cashier,
                              onTap: () => _onCashierTapped(cashier),
                            )
                                .animate()
                                .fadeIn(
                                  duration: 600.ms,
                                  delay: Duration(milliseconds: 100 * index),
                                )
                                .scaleXY(
                                  begin: 0.95,
                                  end: 1.0,
                                  duration: 600.ms,
                                  curve: Curves.easeOutBack,
                                  delay: Duration(milliseconds: 100 * index),
                                );
                          },
                        ),
            ),

            // ── Admin Login Button ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: textSecondary.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextButton(
                  onPressed: () => context.push(RouteConstants.adminLogin),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.admin_panel_settings_outlined, size: 18, color: textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        'Admin Portal',
                        style: GoogleFonts.dmSans(
                          color: textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
          ],
        ),
      ),
    );
  }
}
