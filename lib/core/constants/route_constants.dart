/// RouteConstants defines all named routes for GoRouter.
class RouteConstants {
  // ── Shared ────────────────────────────────────────────────
  static const String splash = '/';
  static const String cashierSelect = '/cashier-select';

  // ── Onboarding ─────────────────────────────────────────────
  static const String welcome = '/welcome';
  static const String signup = '/signup';
  static const String verifyEmail = '/verify-email';
  static const String setupWizard = '/setup-wizard';

  // ── Auth ──────────────────────────────────────────────────
  static const String cashierPin = '/cashier/pin';
  static const String adminLogin = '/admin/login';

  // ── Cashier Shell ─────────────────────────────────────────
  static const String cashierHome = '/cashier/home';
  static const String newOrder = '/cashier/new-order';
  static const String checkout = '/cashier/checkout';
  static const String paymentSuccess = '/cashier/payment-success';
  static const String orderHistory = '/cashier/orders';
  static const String cashierProfile = '/cashier/profile';

  // ── Admin Shell ───────────────────────────────────────────
  static const String adminHome = '/admin/home';
  static const String adminUsers = '/admin/users';
  static const String adminMenuCats = '/admin/menu/categories';
  static const String adminMenuItems = '/admin/menu/items';
  static const String adminVoids = '/admin/void-refund';
  static const String adminReports = '/admin/reports';
  static const String adminEndOfDay = '/admin/end-of-day';
  static const String adminSettings = '/admin/settings';
}
