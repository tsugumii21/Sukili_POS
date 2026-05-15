import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/services/isar_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/isar_collections/store_collection.dart';

/// SplashScreen — The "Modern Brand Evolution" design.
/// Features a rounded-rectangle logo container, Plus Jakarta Sans, and fintech gradient.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 3500));
    if (!mounted) return;

    // Check if a store has been set up locally
    final isar = IsarService.instance.isar;
    final store = await isar.storeCollections
        .filter()
        .isDeletedEqualTo(false)
        .findFirst();

    if (!mounted) return;

    if (store == null) {
      // No store set up yet → show welcome/onboarding
      context.go(RouteConstants.welcome);
    } else {
      // Store exists → go to cashier selection (existing behavior)
      context.go(RouteConstants.cashierSelect);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.15),
            radius: 1.0,
            colors: [
              Color(0xFF8B4049), // Lighter Maroon
              Color(0xFF2A1215), // Deep Dark Maroon
            ],
          ),
        ),
        child: Stack(
          children: [
            // Subtle geometric background element
            Positioned(
              top: -100,
              right: -100,
              child: Opacity(
                opacity: 0.03,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo Container: Rounded Box with Curve Edges
                  Container(
                    width: 140, // Container size
                    height: 140,
                    padding: const EdgeInsets.all(
                        32), // Padding to make the internal logo smaller
                    decoration: BoxDecoration(
                      color: AppColors
                          .primaryLightVariant, // Cream background for the box
                      borderRadius: BorderRadius.circular(40), // Curved edges
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 40,
                          spreadRadius: 0,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/sukli_logo.png',
                      fit: BoxFit.contain,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 1200.ms, curve: Curves.easeInQuad)
                      .scaleXY(
                          begin: 0.8,
                          end: 1.0,
                          duration: 1200.ms,
                          curve: Curves.easeOutBack),

                  const SizedBox(height: 54),

                  // App Title
                  Text(
                    'Sukli',
                    style: GoogleFonts.dmSans(
                      color: AppColors.primaryLightVariant,
                      fontSize: 58,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.5,
                    ),
                  ).animate().fadeIn(duration: 800.ms, delay: 600.ms).slideY(
                      begin: 0.1, end: 0, duration: 800.ms, delay: 600.ms),

                  const SizedBox(height: 4),

                  // Subtext
                  Text(
                    'Smart Point of Sale',
                    style: GoogleFonts.dmSans(
                      color: AppColors.primaryLight.withValues(alpha: 0.6),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ).animate().fadeIn(duration: 800.ms, delay: 1200.ms),
                ],
              ),
            ),

            // Minimal Progress line
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 48,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: 12,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLightVariant
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ).animate(onPlay: (c) => c.repeat()).moveX(
                          begin: -12,
                          end: 48,
                          duration: 1500.ms,
                          curve: Curves.easeInOutSine),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
