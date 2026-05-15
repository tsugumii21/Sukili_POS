import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/isar_collections/user_collection.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/users_provider.dart';

/// UserFormScreen — create or edit a user.
/// Pass [user] for edit mode; leave null for create mode.
class UserFormScreen extends ConsumerStatefulWidget {
  const UserFormScreen({super.key, this.user});

  /// If non-null, the form is in edit mode and pre-fills from this user.
  final UserCollection? user;

  @override
  ConsumerState<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends ConsumerState<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _pinCtrl;

  String _role = 'cashier';
  String _status = 'active';
  bool _obscurePin = true;
  bool _isSaving = false;

  bool get _isEdit => widget.user != null;

  static const _maroon = Color(0xFF8B4049);

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nameCtrl = TextEditingController(text: u?.name ?? '');
    _emailCtrl = TextEditingController(text: u?.email ?? '');
    _pinCtrl = TextEditingController();
    _role = u?.role ?? 'cashier';
    _status = u?.status ?? 'active';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  // ── Save ────────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    try {
      if (_isEdit) {
        await ref.read(usersProvider.notifier).updateUser(
              user: widget.user!,
              name: _nameCtrl.text,
              email: _emailCtrl.text,
              role: _role,
              status: _status,
              newPin: _role == 'cashier' && _pinCtrl.text.length == 4
                  ? _pinCtrl.text
                  : null,
            );
      } else {
        await ref.read(usersProvider.notifier).createUser(
              name: _nameCtrl.text,
              email: _emailCtrl.text,
              role: _role,
              pin: _role == 'cashier' ? _pinCtrl.text : null,
              status: _status,
            );
      }
      if (mounted) {
        _showSnack('User saved successfully.', AppColors.successLight);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Error: $e', AppColors.errorLight);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Reset PIN dialog ─────────────────────────────────────────────────────

  Future<void> _showResetPinDialog() async {
    final ctrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Reset PIN',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter a new 4-digit PIN for ${widget.user!.name}.',
              style: GoogleFonts.dmSans(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'New PIN',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.dmSans()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Reset',
              style: GoogleFonts.dmSans(
                color: _maroon,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && ctrl.text.length == 4 && mounted) {
      try {
        await ref
            .read(usersProvider.notifier)
            .resetPin(widget.user!, ctrl.text);
        if (mounted) {
          _showSnack('PIN reset successfully.', AppColors.successLight);
        }
      } catch (e) {
        if (mounted) {
          _showSnack('Error resetting PIN: $e', AppColors.errorLight);
        }
      }
    }
  }

  // ── Delete confirmation ──────────────────────────────────────────────────

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          'Delete User',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete ${widget.user!.name}? This cannot be undone.',
          style: GoogleFonts.dmSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text('Cancel', style: GoogleFonts.dmSans()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(
              'Delete',
              style: GoogleFonts.dmSans(
                color: AppColors.errorLight,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(usersProvider.notifier).softDelete(widget.user!);
      if (mounted) Navigator.pop(context, true);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(msg, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? 'Edit User' : 'Add User',
          style: AppTextStyles.bodySemiBold(context),
        ),
        centerTitle: true,
        actions: _isEdit
            ? [
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded,
                      color: AppColors.errorLight),
                  onPressed: _confirmDelete,
                  tooltip: 'Delete user',
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Avatar preview ───────────────────────────────────────
                Center(
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _nameCtrl,
                    builder: (_, value, __) {
                      final initial = value.text.isNotEmpty
                          ? value.text[0].toUpperCase()
                          : '?';
                      return Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _maroon.withValues(alpha: 0.12),
                          border: Border.all(
                            color: _maroon.withValues(alpha: 0.25),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: GoogleFonts.dmSans(
                              color: _maroon,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Name ─────────────────────────────────────────────────
                AppTextField(
                  controller: _nameCtrl,
                  label: 'Full Name',
                  hint: 'e.g. Maria Santos',
                  prefixIcon: Icon(Icons.person_outline_rounded,
                      color: textPrimary.withValues(alpha: 0.4), size: 20),
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Name is required';
                    if (v.trim().length < 2) return 'Name is too short';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Email ─────────────────────────────────────────────────
                AppTextField(
                  controller: _emailCtrl,
                  label: 'Email',
                  hint: 'e.g. maria@suklipos.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icon(Icons.alternate_email_rounded,
                      color: textPrimary.withValues(alpha: 0.4), size: 20),
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Role dropdown ─────────────────────────────────────────
                _SectionHeader(label: 'Role', context: context),
                const SizedBox(height: AppSpacing.xs),
                _RoleSelector(
                  selected: _role,
                  onChanged: (r) => setState(() => _role = r),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── PIN (cashiers only) ───────────────────────────────────
                if (_role == 'cashier') ...[
                  AppTextField(
                    controller: _pinCtrl,
                    label: _isEdit
                        ? 'New PIN (leave blank to keep)'
                        : 'PIN (4 digits)',
                    hint: '••••',
                    obscureText: _obscurePin,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icon(Icons.lock_outline_rounded,
                        color: textPrimary.withValues(alpha: 0.4), size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePin
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: textPrimary.withValues(alpha: 0.4),
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePin = !_obscurePin),
                    ),
                    textInputAction: TextInputAction.done,
                    validator: (v) {
                      if (!_isEdit) {
                        if (v == null || v.isEmpty) return 'PIN is required';
                        if (v.length != 4)
                          return 'PIN must be exactly 4 digits';
                        if (!RegExp(r'^\d{4}$').hasMatch(v)) {
                          return 'PIN must be digits only';
                        }
                      } else {
                        if (v != null && v.isNotEmpty) {
                          if (v.length != 4)
                            return 'PIN must be exactly 4 digits';
                          if (!RegExp(r'^\d{4}$').hasMatch(v)) {
                            return 'PIN must be digits only';
                          }
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // ── Status toggle ─────────────────────────────────────────
                _SectionHeader(label: 'Status', context: context),
                const SizedBox(height: AppSpacing.xs),
                _StatusToggle(
                  isActive: _status == 'active',
                  onChanged: (v) =>
                      setState(() => _status = v ? 'active' : 'inactive'),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ── Reset PIN (edit + cashier) ────────────────────────────
                if (_isEdit && widget.user!.role == 'cashier') ...[
                  OutlinedButton.icon(
                    onPressed: _showResetPinDialog,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _maroon,
                      side: BorderSide(color: _maroon.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.lock_reset_rounded, size: 20),
                    label: Text(
                      'Reset PIN',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // ── Save button ───────────────────────────────────────────
                AppPrimaryButton(
                  label: _isEdit ? 'Save Changes' : 'Add User',
                  icon:
                      _isEdit ? Icons.check_rounded : Icons.person_add_rounded,
                  onPressed: _isSaving ? null : _save,
                  isLoading: _isSaving,
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.context});
  final String label;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    return Text(
      label,
      style: GoogleFonts.dmSans(
        color:
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ── Role Selector ─────────────────────────────────────────────────────────────

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Row(
      children: [
        Expanded(
          child: _RoleOption(
            label: 'Cashier',
            icon: Icons.point_of_sale_rounded,
            isSelected: selected == 'cashier',
            onTap: () => onChanged('cashier'),
            textColor: textPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _RoleOption(
            label: 'Admin',
            icon: Icons.admin_panel_settings_outlined,
            isSelected: selected == 'admin',
            onTap: () => onChanged('admin'),
            textColor: textPrimary,
          ),
        ),
      ],
    );
  }
}

class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.textColor,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color textColor;

  static const _maroon = Color(0xFF8B4049);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? _maroon.withValues(alpha: isDark ? 0.25 : 0.1)
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? _maroon.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: isSelected ? _maroon : textColor.withValues(alpha: 0.5)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.dmSans(
                color: isSelected ? _maroon : textColor.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status Toggle ─────────────────────────────────────────────────────────────

class _StatusToggle extends StatelessWidget {
  const _StatusToggle({required this.isActive, required this.onChanged});
  final bool isActive;
  final ValueChanged<bool> onChanged;

  static const _maroon = Color(0xFF8B4049);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: isActive ? AppColors.successLight : AppColors.errorLight,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              isActive ? 'Active' : 'Inactive',
              style: GoogleFonts.dmSans(
                color: textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch.adaptive(
            value: isActive,
            onChanged: onChanged,
            activeThumbColor: _maroon,
            activeTrackColor: _maroon.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.withValues(alpha: 0.15),
          ),
        ],
      ),
    );
  }
}
