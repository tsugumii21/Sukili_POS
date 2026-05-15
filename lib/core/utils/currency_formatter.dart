import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// CurrencyFormatter ensures consistent Philippine Peso display.
class CurrencyFormatter {
  static final _format = NumberFormat.currency(
    symbol: AppConstants.currencySymbol,
    decimalDigits: 2,
    locale: 'en_PH',
  );

  static final _compactFormat = NumberFormat.compactCurrency(
    symbol: AppConstants.currencySymbol,
    locale: 'en_PH',
  );

  /// Returns: ₱1,234.50
  static String format(double amount) => _format.format(amount);

  /// Returns: ₱1.2K or ₱1.2M
  static String formatCompact(double amount) => _compactFormat.format(amount);

  /// Strips currency symbols and parses to double
  static double parse(String value) {
    if (value.isEmpty) return 0.0;
    try {
      final clean =
          value.replaceAll(AppConstants.currencySymbol, '').replaceAll(',', '');
      return double.parse(clean.trim());
    } catch (_) {
      return 0.0;
    }
  }
}
