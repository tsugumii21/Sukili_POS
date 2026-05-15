import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:uuid/uuid.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/services/isar_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/image_compress_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/isar_collections/store_collection.dart';
import '../../../../shared/isar_collections/sync_queue_collection.dart';
import '../../../../shared/isar_collections/user_collection.dart';
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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Sign up with Supabase Auth
      final authResponse = await SupabaseService.instance.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        data: {'name': _nameCtrl.text.trim()},
        emailRedirectTo: 'com.suklipos.sukli_pos://auth-callback',
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
        final compressed =
            await ImageCompressHelper.compressStoreLogo(_logoFile!);
        final bytes = await compressed.readAsBytes();
        final path = 'logos/$storeSyncId.jpg';
        await SupabaseService.instance.client.storage
            .from(SupabaseConstants.storageStoreAssets)
            .uploadBinary(path, bytes,
                fileOptions: const sb.FileOptions(contentType: 'image/jpeg'));
        await ImageCompressHelper.deleteTempFile(compressed);
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
      final storeSyncEntry =
          _createSyncEntry(SupabaseConstants.storesTable, storeSyncId, {
        'sync_id': storeSyncId,
        'name': store.name,
        'logo_url': logoUrl,
        'owner_id': adminSyncId,
        'supabase_auth_uid': authUid,
        'is_active': true,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'is_deleted': false,
      });
      final adminSyncEntry =
          _createSyncEntry(SupabaseConstants.usersTable, adminSyncId, {
        'sync_id': adminSyncId,
        'store_id': storeSyncId,
        'name': admin.name,
        'email': admin.email,
        'role': 'admin',
        'status': 'active',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
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
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteConstants.welcome);
            }
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.arrow_back_rounded, color: textPrimary, size: 20),
          ),
        ),
        title: Text(
          'Create Your Store',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Header text
                Text(
                  'Store Setup',
                  style: GoogleFonts.dmSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fill in your details to get started.',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: textSecondary,
                  ),
                ),

                const SizedBox(height: 28),

                // Logo picker — centered
                Center(
                  child: GestureDetector(
                    onTap: _pickLogo,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.cardDark
                                : AppColors.cardLight,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: _logoFile != null
                                  ? accent
                                  : isDark
                                      ? AppColors.primaryDark
                                      : AppColors.primaryLight,
                              width: _logoFile != null ? 2.5 : 1.5,
                            ),
                            image: _logoFile != null
                                ? DecorationImage(
                                    image: FileImage(_logoFile!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _logoFile == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.store_rounded,
                                        size: 32,
                                        color: accent.withValues(alpha: 0.45)),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Add Logo',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                        Positioned(
                          right: -4,
                          bottom: -4,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                              border: Border.all(color: bg, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt_rounded,
                                size: 15, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Form fields — each with section label above
                _SignUpField(
                  label: 'STORE NAME',
                  child: AppTextField(
                    hint: "e.g. Juan's Carinderia",
                    controller: _storeNameCtrl,
                    prefixIcon: Icon(Icons.store_rounded,
                        color: textSecondary, size: 20),
                    validator: (v) => (v == null || v.trim().length < 2)
                        ? 'Enter a valid store name'
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                _SignUpField(
                  label: 'YOUR NAME',
                  child: AppTextField(
                    hint: 'e.g. Juan Dela Cruz',
                    controller: _nameCtrl,
                    prefixIcon: Icon(Icons.person_outline_rounded,
                        color: textSecondary, size: 20),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter your name'
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                _SignUpField(
                  label: 'EMAIL ADDRESS',
                  child: AppTextField(
                    hint: 'you@email.com',
                    controller: _emailCtrl,
                    prefixIcon: Icon(Icons.email_outlined,
                        color: textSecondary, size: 20),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                          .hasMatch(v.trim())) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _SignUpField(
                  label: 'PASSWORD',
                  child: AppTextField(
                    hint: 'Min. 8 characters',
                    controller: _passwordCtrl,
                    prefixIcon: Icon(Icons.lock_outline_rounded,
                        color: textSecondary, size: 20),
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: textSecondary,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) => (v == null || v.length < 8)
                        ? 'Min. 8 characters'
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                _SignUpField(
                  label: 'CONFIRM PASSWORD',
                  child: AppTextField(
                    hint: 'Re-enter your password',
                    controller: _confirmCtrl,
                    prefixIcon: Icon(Icons.lock_outline_rounded,
                        color: textSecondary, size: 20),
                    obscureText: _obscureConfirm,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: textSecondary,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    validator: (v) => v != _passwordCtrl.text
                        ? 'Passwords do not match'
                        : null,
                  ),
                ),

                // Error message
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.errorLight.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 16, color: AppColors.errorLight),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: AppColors.errorLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Terms
                Center(
                  child: Text(
                    'By continuing you agree to our Terms of Service.',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 16),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Create Store Account',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                Center(
                  child: GestureDetector(
                    onTap: () => context.push(RouteConstants.adminLogin),
                    child: Text(
                      'I already have a store account',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: accent,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows a section label above each form field.
class _SignUpField extends StatelessWidget {
  const _SignUpField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textSecondary,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
