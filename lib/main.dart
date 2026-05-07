import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/services/isar_service.dart';
import 'core/services/supabase_service.dart';
import 'core/services/sync_service.dart';
import 'core/utils/seed_data.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow google_fonts to fetch and cache DM Sans at runtime (works offline
  // after first fetch via flutter_cache_manager under the hood).
  GoogleFonts.config.allowRuntimeFetching = true;

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize core services
  await IsarService.instance.init();
  await SupabaseService.instance.init();
  SyncService.instance.startPeriodicSync();

  // Remove legacy demo accounts
  await SeedData.cleanupLegacyData(IsarService.instance.isar);

  runApp(const ProviderScope(child: SukliPosApp()));
}
