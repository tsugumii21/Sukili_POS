import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import '../constants/supabase_constants.dart';

/// SupabaseService handles all cloud interactions and Auth.
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._();
  SupabaseService._();
  factory SupabaseService() => _instance;

  Future<void> initialize() async {
    // Already initialized in main.dart
  }

  SupabaseClient get client => Supabase.instance.client;
  GoTrueClient get auth => client.auth;

  // --- AUTH METHODS ---

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      return await auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw AuthException(e.message, code: e.statusCode);
    } catch (e) {
      throw AuthException('Sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  User? get currentUser => auth.currentUser;
  Stream<AuthState> get authStateChanges => auth.onAuthStateChange;

  // --- SYNC CRUD METHODS ---

  Future<void> upsertRecord(String table, Map<String, dynamic> data) async {
    try {
      await client.from(table).upsert(data, onConflict: SupabaseConstants.syncId);
    } catch (e) {
      throw SyncException('Supabase upsert failed on table $table: $e');
    }
  }

  Future<void> softDelete(String table, String syncId) async {
    try {
      await client.from(table).update({SupabaseConstants.isDeleted: true}).eq(SupabaseConstants.syncId, syncId);
    } catch (e) {
      throw SyncException('Supabase soft-delete failed on table $table: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchUpdatedSince(String table, DateTime since) async {
    try {
      final response = await client
          .from(table)
          .select()
          .gt(SupabaseConstants.updatedAt, since.toIso8601String())
          .order(SupabaseConstants.updatedAt);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw SyncException('Supabase fetch failed on table $table: $e');
    }
  }
}
