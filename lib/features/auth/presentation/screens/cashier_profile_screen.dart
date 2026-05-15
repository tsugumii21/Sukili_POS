import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/image_compress_helper.dart';
import '../../../../core/utils/pin_helper.dart';
import '../../../../shared/isar_collections/sync_queue_collection.dart';
import '../../../../shared/isar_collections/user_collection.dart';
import '../../../../shared/providers/isar_provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/widgets/app_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CashierProfileScreen
// ─────────────────────────────────────────────────────────────────────────────

class CashierProfileScreen extends ConsumerStatefulWidget {
  const CashierProfileScreen({super.key});

  @override
  ConsumerState<CashierProfileScreen> createState() =>
      _CashierProfileScreenState();
}

class _CashierProfileScreenState extends ConsumerState<CashierProfileScreen> {
  // ── Controllers ─────────────────────────────────────────────────────────────
  final _nameCtrl = TextEditingController();
  final _currentPinCtrl = TextEditingController();
  final _newPinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // ── State ────────────────────────────────────────────────────────────────────
  String? _localAvatarPath;
  bool _isSaving = false;
  bool _showSuccess = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  static const _uuid = Uuid();

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _prefillForm();
  }

  void _prefillForm() {
    final cashier = ref.read(authProvider).selectedCashier;
    if (cashier == null) return;
    _nameCtrl.text = cashier.name;
    if (cashier.avatarUrl != null && cashier.avatarUrl!.startsWith('/')) {
      _localAvatarPath = cashier.avatarUrl;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _currentPinCtrl.dispose();
    _newPinCtrl.dispose();
    _confirmPinCtrl.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark.withAlpha(180)
        : const Color(0xFF8A8A8A);
    final inputBorder = isDark ? AppColors.cardDark : const Color(0xFFE0D0C8);

    final authState = ref.watch(authProvider);
    final cashier = authState.selectedCashier;
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    if (cashier == null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: _buildAppBar(textPrimary, context),
        body: Center(
          child: Text(
            'No cashier logged in.',
            style: GoogleFonts.dmSans(color: textSecondary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: _buildAppBar(textPrimary, context),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero header ──────────────────────────────────────────
                _HeroHeader(
                  cashier: cashier,
                  localPath: _localAvatarPath,
                  onPickPhoto: _pickPhoto,
                ).animate().fadeIn(duration: 350.ms),

                // ── Scrollable body ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.xxl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Profile Information ──────────────────────────
                      _SectionLabel(
                        label: 'Profile Information',
                        textSecondary: textSecondary,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      AppCard(
                        padding: EdgeInsets.zero,
                        borderRadius: AppRadius.largeBR,
                        child: Column(
                          children: [
                            _EditableRow(
                              controller: _nameCtrl,
                              label: 'Display Name',
                              icon: Icons.badge_outlined,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              inputBorder: inputBorder,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Name cannot be empty'
                                  : null,
                            ),
                            _RowDivider(color: textSecondary),
                            _ReadOnlyRow(
                              label: 'Username',
                              value: cashier.email,
                              icon: Icons.alternate_email_rounded,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                            ),
                            _RowDivider(color: textSecondary),
                            _RoleRow(
                              role: cashier.role,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 80.ms, duration: 320.ms).slideY(
                            begin: 0.04,
                            end: 0,
                            delay: 80.ms,
                            duration: 320.ms,
                            curve: Curves.easeOut,
                          ),

                      const SizedBox(height: AppSpacing.lg),

                      // ── Security ─────────────────────────────────────
                      _SectionLabel(
                        label: 'Security',
                        textSecondary: textSecondary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cashier.pinHash == null
                            ? 'No PIN set. Set one below.'
                            : 'Enter your current PIN to set a new one.',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      AppCard(
                        padding: EdgeInsets.zero,
                        borderRadius: AppRadius.largeBR,
                        child: Column(
                          children: [
                            if (cashier.pinHash != null) ...[
                              _PinInputRow(
                                controller: _currentPinCtrl,
                                label: 'Current PIN',
                                obscure: _obscureCurrent,
                                onToggle: () => setState(
                                    () => _obscureCurrent = !_obscureCurrent),
                              ),
                              _RowDivider(color: textSecondary),
                            ],
                            _PinInputRow(
                              controller: _newPinCtrl,
                              label: 'New PIN',
                              obscure: _obscureNew,
                              onToggle: () =>
                                  setState(() => _obscureNew = !_obscureNew),
                            ),
                            _RowDivider(color: textSecondary),
                            _PinInputRow(
                              controller: _confirmPinCtrl,
                              label: 'Confirm New PIN',
                              obscure: _obscureConfirm,
                              onToggle: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 130.ms, duration: 320.ms)
                          .slideY(
                            begin: 0.04,
                            end: 0,
                            delay: 130.ms,
                            duration: 320.ms,
                            curve: Curves.easeOut,
                          ),

                      const SizedBox(height: AppSpacing.lg),

                      // ── Save button with success flash ───────────────
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _showSuccess
                            ? Container(
                                key: const ValueKey('success'),
                                width: double.infinity,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.successLight,
                                  borderRadius: AppRadius.largeBR,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Changes Saved!',
                                      style: GoogleFonts.dmSans(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                .animate()
                                .scale(
                                  begin: const Offset(0.94, 0.94),
                                  duration: 200.ms,
                                  curve: Curves.easeOut,
                                )
                                .fadeIn(duration: 180.ms)
                            : SizedBox(
                                key: const ValueKey('save'),
                                width: double.infinity,
                                height: 60,
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : _saveChanges,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accentLight,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        AppColors.accentLight.withAlpha(100),
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: AppRadius.largeBR,
                                    ),
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Text(
                                          'Save Changes',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.1,
                                          ),
                                        ),
                                ),
                              ),
                      ).animate().fadeIn(delay: 170.ms, duration: 320.ms),

                      const SizedBox(height: AppSpacing.lg),

                      // ── Preferences ──────────────────────────────────
                      _SectionLabel(
                        label: 'Preferences',
                        textSecondary: textSecondary,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      AppCard(
                        padding: EdgeInsets.zero,
                        borderRadius: AppRadius.largeBR,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: 4,
                          ),
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: (isDarkMode
                                      ? Colors.amber.shade700
                                      : Colors.orange.shade400)
                                  .withAlpha(22),
                              borderRadius: AppRadius.smallBR,
                            ),
                            child: Icon(
                              isDarkMode
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
                              color: isDarkMode
                                  ? Colors.amber.shade400
                                  : Colors.orange.shade500,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            isDarkMode ? 'Dark Mode' : 'Light Mode',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            isDarkMode
                                ? 'Switch to light theme'
                                : 'Switch to dark theme',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: textSecondary,
                            ),
                          ),
                          trailing: Switch.adaptive(
                            value: isDarkMode,
                            onChanged: (_) =>
                                ref.read(themeProvider.notifier).toggle(),
                            activeThumbColor: AppColors.accentLight,
                            activeTrackColor:
                                AppColors.accentLight.withValues(alpha: 0.5),
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 320.ms),

                      const SizedBox(height: AppSpacing.xl),

                      // ── Logout ───────────────────────────────────────
                      Center(
                        child: TextButton.icon(
                          onPressed: () => _confirmLogout(context),
                          icon: const Icon(
                            Icons.power_settings_new_rounded,
                            color: AppColors.errorLight,
                            size: 20,
                          ),
                          label: Text(
                            'Logout',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.errorLight,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.errorLight,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.sm,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.pillBR,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 230.ms, duration: 320.ms),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── AppBar ───────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(Color textPrimary, BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: textPrimary,
          size: 20,
        ),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RouteConstants.cashierHome);
          }
        },
      ),
      title: Text(
        'My Profile',
        style: GoogleFonts.dmSans(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  // ── Image picker ─────────────────────────────────────────────────────────────

  Future<void> _pickPhoto() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (file != null && mounted) {
        setState(() => _localAvatarPath = file.path);
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not pick image: ${e.message}',
            style: GoogleFonts.dmSans()),
        backgroundColor: AppColors.secondaryLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smallBR),
      ));
    }
  }

  // ── Save changes ─────────────────────────────────────────────────────────────

  Future<void> _saveChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final cashier = ref.read(authProvider).selectedCashier;
    if (cashier == null) return;

    final isChangingPin = _newPinCtrl.text.isNotEmpty ||
        _confirmPinCtrl.text.isNotEmpty ||
        _currentPinCtrl.text.isNotEmpty;

    if (isChangingPin) {
      if (cashier.pinHash != null) {
        if (_currentPinCtrl.text.isEmpty) {
          _showError('Please enter your current PIN.');
          return;
        }
        if (!PinHelper.verifyPin(_currentPinCtrl.text, cashier.pinHash!)) {
          _showError('Current PIN is incorrect.');
          return;
        }
      }
      if (_newPinCtrl.text.length != AppConstants.pinLength) {
        _showError('New PIN must be exactly ${AppConstants.pinLength} digits.');
        return;
      }
      if (_newPinCtrl.text != _confirmPinCtrl.text) {
        _showError('New PINs do not match.');
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      final isar = ref.read(isarProvider);
      final now = DateTime.now();

      cashier
        ..name = _nameCtrl.text.trim()
        ..updatedAt = now
        ..isSynced = false;

      if (_localAvatarPath != null && !_localAvatarPath!.startsWith('http')) {
        final url =
            await _uploadAvatar(File(_localAvatarPath!), cashier.syncId);
        if (url != null) cashier.avatarUrl = url;
      }

      if (isChangingPin) {
        cashier.pinHash = PinHelper.hashPin(_newPinCtrl.text);
      }

      final payload = jsonEncode({
        'sync_id': cashier.syncId,
        'email': cashier.email,
        'name': cashier.name,
        'pin_hash': cashier.pinHash,
        'role': cashier.role,
        'status': cashier.status,
        'avatar_url': cashier.avatarUrl,
        'updated_at': now.toIso8601String(),
      });

      final syncEntry = SyncQueueCollection()
        ..operationId = _uuid.v4()
        ..tableName = 'users'
        ..recordSyncId = cashier.syncId
        ..operation = 'update'
        ..payloadJson = payload
        ..retryCount = 0
        ..maxRetries = AppConstants.maxSyncRetries
        ..status = 'pending'
        ..createdAt = now;

      await isar.writeTxn(() async {
        await isar.userCollections.put(cashier);
        await isar.syncQueueCollections.put(syncEntry);
      });

      ref.read(authProvider.notifier).selectCashier(cashier);

      _currentPinCtrl.clear();
      _newPinCtrl.clear();
      _confirmPinCtrl.clear();

      // Success flash animation
      if (mounted) {
        setState(() => _showSuccess = true);
        Future.delayed(const Duration(milliseconds: 1800), () {
          if (mounted) setState(() => _showSuccess = false);
        });
      }
    } catch (e) {
      _showError('Failed to save: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────────────

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.largeBR),
        title: Text(
          'Logout',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.dmSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
              context.go(RouteConstants.cashierSelect);
            },
            child: Text(
              'Logout',
              style: GoogleFonts.dmSans(
                color: AppColors.errorLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.dmSans()),
        backgroundColor: AppColors.secondaryLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smallBR),
      ),
    );
  }

  Future<String?> _uploadAvatar(File avatarFile, String userSyncId) async {
    try {
      final compressed = await ImageCompressHelper.compressAvatar(avatarFile);
      final bytes = await compressed.readAsBytes();
      final storagePath = 'avatars/$userSyncId.jpg';

      await SupabaseService.instance.client.storage
          .from(SupabaseConstants.storageStoreAssets)
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: const sb.FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      await ImageCompressHelper.deleteTempFile(compressed);

      return SupabaseService.instance.client.storage
          .from(SupabaseConstants.storageStoreAssets)
          .getPublicUrl(storagePath);
    } catch (e) {
      debugPrint('Avatar upload failed: $e');
      return null;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero header with ClipPath gradient
// ─────────────────────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.cashier,
    required this.localPath,
    required this.onPickPhoto,
  });

  final UserCollection cashier;
  final String? localPath;
  final VoidCallback onPickPhoto;

  @override
  Widget build(BuildContext context) {
    final initial =
        cashier.name.isNotEmpty ? cashier.name[0].toUpperCase() : '?';
    final topPad = MediaQuery.of(context).padding.top;

    Widget avatarWidget;
    if (localPath != null) {
      avatarWidget = CircleAvatar(
        radius: 45,
        backgroundImage: FileImage(File(localPath!)),
      );
    } else if (cashier.avatarUrl != null &&
        cashier.avatarUrl!.isNotEmpty &&
        !cashier.avatarUrl!.startsWith('/')) {
      avatarWidget = CircleAvatar(
        radius: 45,
        backgroundImage: NetworkImage(cashier.avatarUrl!),
        backgroundColor: Colors.white24,
      );
    } else {
      avatarWidget = CircleAvatar(
        radius: 45,
        backgroundColor: Colors.white.withAlpha(30),
        child: Text(
          initial,
          style: GoogleFonts.dmSans(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      );
    }

    return ClipPath(
      clipper: _HeaderClipper(),
      child: Container(
        height: 220 + topPad,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.secondaryLight, AppColors.accentLight],
          ),
        ),
        padding: EdgeInsets.only(top: topPad),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: AppShadow.level3,
                    ),
                    child: avatarWidget,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: onPickPhoto,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: AppShadow.level2,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: AppColors.accentLight,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().scale(
                    begin: const Offset(0.85, 0.85),
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

// Gentle outward curve at the bottom of the header
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 48);
    path.cubicTo(
      size.width * 0.25,
      size.height + 12,
      size.width * 0.75,
      size.height + 12,
      size.width,
      size.height - 48,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_HeaderClipper oldClipper) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label with accent bar
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.textSecondary});

  final String label;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 13,
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: AppRadius.pillBR,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.dmSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: textSecondary,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Row divider inside AppCard
// ─────────────────────────────────────────────────────────────────────────────

class _RowDivider extends StatelessWidget {
  const _RowDivider({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, color: color.withAlpha(40), indent: 16, endIndent: 16);
}

// ─────────────────────────────────────────────────────────────────────────────
// Editable field row
// ─────────────────────────────────────────────────────────────────────────────

class _EditableRow extends StatelessWidget {
  const _EditableRow({
    required this.controller,
    required this.label,
    required this.icon,
    required this.textPrimary,
    required this.textSecondary,
    required this.inputBorder,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color textPrimary;
  final Color textSecondary;
  final Color inputBorder;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: AppRadius.smallBR,
            ),
            child: Icon(icon, size: 18, color: textSecondary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextFormField(
                  controller: controller,
                  validator: validator,
                  textInputAction: TextInputAction.done,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.only(top: 4),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: inputBorder, width: 1),
                    ),
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Read-only field row
// ─────────────────────────────────────────────────────────────────────────────

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.textPrimary,
    required this.textSecondary,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: AppRadius.smallBR,
            ),
            child: Icon(icon, size: 18, color: textSecondary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Opacity(
            opacity: 0.45,
            child: Icon(
              Icons.lock_outline_rounded,
              size: 14,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Role badge row
// ─────────────────────────────────────────────────────────────────────────────

class _RoleRow extends StatelessWidget {
  const _RoleRow({
    required this.role,
    required this.textPrimary,
    required this.textSecondary,
  });

  final String role;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: AppRadius.smallBR,
            ),
            child: Icon(Icons.shield_outlined, size: 18, color: textSecondary),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Role',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: AppRadius.pillBR,
                ),
                child: Text(
                  _capitalize(role),
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom 4-box PIN input row
// ─────────────────────────────────────────────────────────────────────────────

class _PinInputRow extends StatefulWidget {
  const _PinInputRow({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
  });

  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;

  @override
  State<_PinInputRow> createState() => _PinInputRowState();
}

class _PinInputRowState extends State<_PinInputRow> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
    _focusNode.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    _focusNode.removeListener(_rebuild);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = widget.controller.text;
    final isFocused = _focusNode.hasFocus;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark.withAlpha(160)
        : const Color(0xFF8A8A8A);
    final boxBg = isDark ? AppColors.surfaceDark : AppColors.cardLight;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // 4 boxes with transparent TextField overlay
              GestureDetector(
                onTap: () => _focusNode.requestFocus(),
                child: Stack(
                  children: [
                    // Visual pin boxes
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(4, (i) {
                        final filled = i < text.length;
                        final isActive =
                            isFocused && i == text.length.clamp(0, 3);
                        return Padding(
                          padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 40,
                            height: 48,
                            decoration: BoxDecoration(
                              color: filled
                                  ? AppColors.accentLight.withAlpha(25)
                                  : boxBg,
                              borderRadius: AppRadius.mediumBR,
                              border: Border.all(
                                color: isActive
                                    ? AppColors.accentLight
                                    : (filled
                                        ? AppColors.accentLight.withAlpha(60)
                                        : Colors.transparent),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: filled
                                  ? (widget.obscure
                                      ? Container(
                                          width: 9,
                                          height: 9,
                                          decoration: const BoxDecoration(
                                            color: AppColors.accentLight,
                                            shape: BoxShape.circle,
                                          ),
                                        )
                                      : Text(
                                          text[i],
                                          style: GoogleFonts.dmSans(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.accentLight,
                                          ),
                                        ))
                                  : null,
                            ),
                          ),
                        );
                      }),
                    ),
                    // Invisible TextField captures keyboard input
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.0,
                        child: TextField(
                          controller: widget.controller,
                          focusNode: _focusNode,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          obscureText: false,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Show / hide toggle
              GestureDetector(
                onTap: widget.onToggle,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: AppRadius.smallBR,
                  ),
                  child: Icon(
                    widget.obscure
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 18,
                    color: textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
