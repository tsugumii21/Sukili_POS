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
  static const String supabaseUrl = 'https://nszgseyzrnpwgwbjwyfg.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5zemdzZXl6cm5wd2d3Ymp3eWZnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ4NjQwMTMsImV4cCI6MjA5MDQ0MDAxM30.kWXB7bCde17afEEgcA025JwWbTydfBGKKnFO6NYubKg';
}
