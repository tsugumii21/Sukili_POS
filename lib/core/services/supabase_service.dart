import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import '../constants/supabase_constants.dart';

/// SupabaseService handles all remote database interactions.
class SupabaseService {
  SupabaseService._();

  static final SupabaseService instance = SupabaseService._();

  sb.SupabaseClient get client => sb.Supabase.instance.client;
  sb.GoTrueClient get auth => client.auth;
  sb.User? get currentUser => auth.currentUser;
  Stream<sb.AuthState> get authStateChanges => auth.onAuthStateChange;

  Future<void> init() async {
    await sb.Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
  }

  // --- AUTH METHODS ---

  Future<sb.AuthResponse> signInWithEmail(String email, String password) async {
    try {
      return await auth.signInWithPassword(email: email, password: password);
    } on sb.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException('Sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  // --- DATA METHODS ---

  Future<List<Map<String, dynamic>>> fetchUpdatedSince(
    String table,
    DateTime lastPull,
  ) async {
    try {
      final response = await client
          .from(table)
          .select()
          .gt(SupabaseConstants.updatedAt, lastPull.toIso8601String())
          .order(SupabaseConstants.updatedAt, ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw DatabaseException('Failed to fetch from Supabase: $e');
    }
  }

  Future<void> upsertRecord(String table, Map<String, dynamic> record) async {
    try {
      await client.from(table).upsert(record);
    } catch (e) {
      throw DatabaseException('Failed to upsert to Supabase: $e');
    }
  }

  Future<void> softDelete(String table, String syncId) async {
    try {
      await client
          .from(table)
          .update({SupabaseConstants.isDeleted: true})
          .eq(SupabaseConstants.syncId, syncId);
    } catch (e) {
      throw DatabaseException('Failed to soft delete in Supabase: $e');
    }
  }

  // --- STORAGE METHODS ---

  /// Uploads [bytes] to the `menu-items` bucket at [path] and returns
  /// the public URL, or null on failure.
  ///
  /// Prerequisites: Create a public bucket named `menu-items` in Supabase
  /// Storage and enable public read access.
  ///
  /// Rejects files larger than 15 MB.
  static const int maxImageBytes = 15 * 1024 * 1024; // 15 MB

  Future<String?> uploadMenuImage(List<int> bytes, String fileName) async {
    if (bytes.length > maxImageBytes) return null;
    try {
      final ext = fileName.contains('.')
          ? fileName.split('.').last.toLowerCase()
          : 'jpg';
      final storagePath =
          '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      await client.storage.from('menu-items').uploadBinary(
            storagePath,
            bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
            fileOptions: sb.FileOptions(contentType: 'image/$ext'),
          );
      return client.storage.from('menu-items').getPublicUrl(storagePath);
    } catch (e) {
      return null;
    }
  }
}
