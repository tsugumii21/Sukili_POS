/// AppConstants defines the logic-based constants for Sukli POS.
class AppConstants {
  // App info
  static const String appName = 'Sukli POS';
  static const String appVersion = '1.0.0';
  
  // PH VAT rate
  static const double vatRate = 0.12;
  
  // PIN
  static const int pinLength = 4;
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Sync
  static const int syncIntervalSeconds = 30;
  static const int maxSyncRetries = 3;
  
  // Inventory
  static const double defaultLowStockThreshold = 5.0;
  
  // Currency
  static const String currencySymbol = '₱';
  static const String currencyCode = 'PHP';
  
  // Order number prefix
  static const String orderPrefix = 'ORD';
  
  // Supabase Configuration
  // Note: Replace these with your actual Supabase dashboard details.
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
