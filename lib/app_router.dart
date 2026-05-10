import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/route_constants.dart';

// ── Auth Screens ──────────────────────────────────────────────────────────────
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/welcome_screen.dart';
import 'features/auth/presentation/screens/sign_up_screen.dart';
import 'features/auth/presentation/screens/verify_email_screen.dart';
import 'features/auth/presentation/screens/setup_wizard_screen.dart';
import 'features/auth/presentation/screens/cashier_selection_screen.dart';
import 'features/auth/presentation/screens/cashier_pin_screen.dart';
import 'features/auth/presentation/screens/admin_login_screen.dart';
import 'features/auth/presentation/screens/cashier_profile_screen.dart';

// ── Cashier Screens ───────────────────────────────────────────────────────────
import 'features/dashboard/presentation/screens/cashier_dashboard_screen.dart';
import 'features/menu/presentation/screens/new_order_screen.dart';
import 'features/checkout/presentation/screens/checkout_screen.dart';
import 'features/checkout/presentation/screens/payment_success_screen.dart';
import 'features/orders/presentation/screens/order_history_screen.dart';

// ── Admin Screens ─────────────────────────────────────────────────────────────
import 'features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import 'features/users/presentation/screens/user_management_screen.dart';
import 'features/menu/presentation/screens/category_management_screen.dart';
import 'features/menu/presentation/screens/item_management_screen.dart';
import 'features/void_refund/presentation/screens/void_refund_screen.dart';
import 'features/reports/presentation/screens/reports_screen.dart';
import 'features/reports/presentation/screens/end_of_day_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteConstants.splash,
    debugLogDiagnostics: true,
    routes: [
      // ── Auth (no shell) ─────────────────────────────────────────────────────
      GoRoute(
        path: RouteConstants.splash,
        builder: (c, s) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteConstants.welcome,
        builder: (c, s) => const WelcomeScreen(),
      ),
      GoRoute(
        path: RouteConstants.signup,
        builder: (c, s) => const SignUpScreen(),
      ),
      GoRoute(
        path: RouteConstants.verifyEmail,
        builder: (c, s) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: RouteConstants.setupWizard,
        builder: (c, s) => const SetupWizardScreen(),
      ),
      GoRoute(
        path: RouteConstants.cashierSelect,
        builder: (c, s) => const CashierSelectionScreen(),
      ),
      GoRoute(
        path: RouteConstants.cashierPin,
        builder: (c, s) => const CashierPinScreen(),
      ),
      GoRoute(
        path: RouteConstants.adminLogin,
        builder: (c, s) => const AdminLoginScreen(),
      ),

      // ── Cashier Shell ────────────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => CashierShell(child: child),
        routes: [
          GoRoute(
            path: RouteConstants.cashierHome,
            builder: (c, s) => const CashierDashboardScreen(),
          ),
          GoRoute(
            path: RouteConstants.newOrder,
            builder: (c, s) => const NewOrderScreen(),
          ),
          GoRoute(
            path: RouteConstants.checkout,
            builder: (c, s) => const CheckoutScreen(),
          ),
          GoRoute(
            path: RouteConstants.paymentSuccess,
            builder: (c, s) => const PaymentSuccessScreen(),
          ),
          GoRoute(
            path: RouteConstants.orderHistory,
            builder: (c, s) => const OrderHistoryScreen(),
          ),
          GoRoute(
            path: RouteConstants.cashierProfile,
            builder: (c, s) => const CashierProfileScreen(),
          ),
        ],
      ),

      // ── Admin Shell ──────────────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: RouteConstants.adminHome,
            builder: (c, s) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: RouteConstants.adminUsers,
            builder: (c, s) => const UserManagementScreen(),
          ),
          GoRoute(
            path: RouteConstants.adminMenuCats,
            builder: (c, s) => const CategoryManagementScreen(),
          ),
          GoRoute(
            path: RouteConstants.adminMenuItems,
            builder: (c, s) => const ItemManagementScreen(),
          ),
          GoRoute(
            path: RouteConstants.adminVoids,
            builder: (c, s) => const VoidRefundScreen(),
          ),
          GoRoute(
            path: RouteConstants.adminReports,
            builder: (c, s) => const ReportsScreen(),
          ),
          GoRoute(
            path: RouteConstants.adminEndOfDay,
            builder: (c, s) => const EndOfDayScreen(),
          ),
          GoRoute(
            path: RouteConstants.adminSettings,
            builder: (c, s) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

// ── Shell Scaffolds ───────────────────────────────────────────────────────────

/// Cashier shell — wraps all cashier routes. Navigation bar added in Part 8.
class CashierShell extends StatelessWidget {
  const CashierShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// Admin shell — wraps all admin routes. Navigation drawer added in Part 8.
class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
