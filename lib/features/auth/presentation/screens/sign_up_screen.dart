import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:uuid/uuid.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/services/isar_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/isar_collections/store_collection.dart';
import '../../../../shared/isar_collections/sync_queue_collection.dart';
import '../../../../shared/isar_collections/user_collection.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';

/// SignUpScreen — Store creation and admin account registration.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;
  File? _logoFile;

  @override
  void dispose() {
    _storeNameCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _logoFile = File(picked.path));
    }
  }

  SyncQueueCollection _createSyncEntry(
      String tableName, String recordSyncId, Map<String, dynamic> payload) {
    return SyncQueueCollection()
      ..operationId =
          '${tableName}_${recordSyncId}_${DateTime.now().millisecondsSinceEpoch}'
      ..tableName = tableName
      ..recordSyncId = recordSyncId
      ..operation = 'insert'
      ..payloadJson = jsonEncode(payload)
      ..status = 'pending'
      ..retryCount = 0
      ..maxRetries = 3
      ..createdAt = DateTime.now();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      // 1. Sign up with Supabase Auth
      final authResponse = await SupabaseService.instance.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        data: {'name': _nameCtrl.text.trim()},
      );

      if (authResponse.user == null) {
        throw const sb.AuthException('Signup failed. Please try again.');
      }

      final authUid = authResponse.user!.id;
      final storeSyncId = const Uuid().v4();
      final adminSyncId = const Uuid().v4();
      final now = DateTime.now();

      // 2. Upload logo (if selected)
      String? logoUrl;
      if (_logoFile != null) {
        final bytes = await _logoFile!.readAsBytes();
        final path = 'logos/$storeSyncId.jpg';
        await SupabaseService.instance.client.storage
            .from(SupabaseConstants.storageStoreAssets)
            .uploadBinary(path, bytes,
                fileOptions: const sb.FileOptions(contentType: 'image/jpeg'));
        logoUrl = SupabaseService.instance.client.storage
            .from(SupabaseConstants.storageStoreAssets)
            .getPublicUrl(path);
      }

      // 3. Create store + admin in Isar
      final store = StoreCollection()
        ..syncId = storeSyncId
        ..name = _storeNameCtrl.text.trim()
        ..logoUrl = logoUrl
        ..ownerId = adminSyncId
        ..supabaseAuthUid = authUid
        ..isActive = true
        ..createdAt = now
        ..updatedAt = now
        ..isSynced = false
        ..isDeleted = false;

      final admin = UserCollection()
        ..syncId = adminSyncId
        ..storeId = storeSyncId
        ..name = _nameCtrl.text.trim()
        ..email = _emailCtrl.text.trim()
        ..pinHash = null
        ..role = 'admin'
        ..status = 'active'
        ..createdAt = now
        ..updatedAt = now
        ..isSynced = false
        ..isDeleted = false;

      final isar = IsarService.instance.isar;
      await isar.writeTxn(() async {
        await isar.storeCollections.put(store);
        await isar.userCollections.put(admin);
      });

      // 4. Enqueue sync
      final storeSyncEntry = _createSyncEntry(SupabaseConstants.storesTable, storeSyncId, {
        'sync_id': storeSyncId, 'name': store.name, 'logo_url': logoUrl,
        'owner_id': adminSyncId, 'supabase_auth_uid': authUid,
        'is_active': true, 'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(), 'is_deleted': false,
      });
      final adminSyncEntry = _createSyncEntry(SupabaseConstants.usersTable, adminSyncId, {
        'sync_id': adminSyncId, 'store_id': storeSyncId, 'name': admin.name,
        'email': admin.email, 'role': 'admin', 'status': 'active',
        'created_at': now.toIso8601String(), 'updated_at': now.toIso8601String(),
        'is_deleted': false,
      });

      await isar.writeTxn(() async {
        await isar.syncQueueCollections.put(storeSyncEntry);
        await isar.syncQueueCollections.put(adminSyncEntry);
      });

      // 5. Navigate to verify email
      if (mounted) {
        context.go(RouteConstants.verifyEmail, extra: _emailCtrl.text.trim());
      }
    } on sb.AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSec = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
          onPressed: () => context.go(RouteConstants.welcome),
        ),
        title: Text('Create Your Store', style: AppTextStyles.h3(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.sm),
                Text('Step 1 of 1', style: AppTextStyles.captionSecondary(context)),
                Text('Store Setup', style: AppTextStyles.h2(context)),
                Text('Fill in your store details to get started.',
                    style: AppTextStyles.bodySecondary(context)),
                const SizedBox(height: AppSpacing.xl),

                // ── Logo Picker ──────────────────────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: _pickLogo,
                    child: Stack(children: [
                      Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.cardLight,
                          borderRadius: AppRadius.largeBR,
                          border: Border.all(color: accent.withValues(alpha: 0.3), width: 2),
                          image: _logoFile != null
                              ? DecorationImage(image: FileImage(_logoFile!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: _logoFile == null
                            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Icon(Icons.store_rounded, size: 32, color: accent.withValues(alpha: 0.6)),
                                const SizedBox(height: 4),
                                Text('Add Logo', style: AppTextStyles.captionSecondary(context)),
                              ])
                            : null,
                      ),
                      Positioned(right: 0, bottom: 0,
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: accent, shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                        ),
                      ),
                    ]),
                  ),
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: AppSpacing.xl),

                // ── Form Fields ──────────────────────────────────────────
                AppCard(
                  child: Column(children: [
                    AppTextField(controller: _storeNameCtrl, label: 'Store Name',
                      hint: "e.g. Juan's Carinderia",
                      prefixIcon: Icon(Icons.store_rounded, color: textSec, size: 20),
                      validator: (v) => (v == null || v.trim().length < 2) ? 'Min 2 characters' : null),
                    Divider(color: accent.withValues(alpha: 0.1)),
                    AppTextField(controller: _nameCtrl, label: 'Your Name',
                      hint: 'e.g. Juan Dela Cruz',
                      prefixIcon: Icon(Icons.person_outline_rounded, color: textSec, size: 20),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null),
                    Divider(color: accent.withValues(alpha: 0.1)),
                    AppTextField(controller: _emailCtrl, label: 'Email Address',
                      hint: 'you@email.com', keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icon(Icons.email_outlined, color: textSec, size: 20),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email is required';
                        if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(v.trim())) {
                          return 'Enter a valid email';
                        }
                        return null;
                      }),
                    Divider(color: accent.withValues(alpha: 0.1)),
                    AppTextField(controller: _passwordCtrl, label: 'Password', hint: 'Min. 8 characters',
                      obscureText: _obscurePassword,
                      prefixIcon: Icon(Icons.lock_outline_rounded, color: textSec, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: textSec, size: 20),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                      validator: (v) => (v == null || v.length < 8) ? 'Min 8 characters' : null),
                    Divider(color: accent.withValues(alpha: 0.1)),
                    AppTextField(controller: _confirmCtrl, label: 'Confirm Password',
                      obscureText: _obscureConfirm,
                      prefixIcon: Icon(Icons.lock_outline_rounded, color: textSec, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: textSec, size: 20),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm)),
                      validator: (v) => v != _passwordCtrl.text ? 'Passwords do not match' : null),
                  ]),
                ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                // Error message
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight.withValues(alpha: 0.1),
                      borderRadius: AppRadius.mediumBR,
                    ),
                    child: Text(_errorMessage!,
                        style: AppTextStyles.caption(context).copyWith(color: AppColors.errorLight),
                        textAlign: TextAlign.center),
                  ),
                ],

                const SizedBox(height: AppSpacing.lg),
                Text('By creating an account you agree to our Terms of Service.',
                    style: AppTextStyles.captionSecondary(context), textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.md),
                AppPrimaryButton(label: 'Create Store Account', isLoading: _isLoading,
                    onPressed: _isLoading ? null : _onSubmit),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
