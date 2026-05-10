import 'package:flutter_dotenv/flutter_dotenv.dart';

/// AppConstants defines the logic-based constants for Sukli POS.
class AppConstants {
  /// Set to true for production builds.
  /// When true, skips all demo seed data on first launch.
  static const bool isProduction = true;

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
  
  // Currency
  static const String currencySymbol = '₱';
  static const String currencyCode = 'PHP';
  
  // Order number prefix
  static const String orderPrefix = 'ORD';
  
  // Supabase Configuration (Safely loaded from .env)
  static String get supabaseUrl => dotenv.get('SUPABASE_URL', fallback: '');
  static String get supabaseAnonKey => dotenv.get('SUPABASE_ANON_KEY', fallback: '');
}
