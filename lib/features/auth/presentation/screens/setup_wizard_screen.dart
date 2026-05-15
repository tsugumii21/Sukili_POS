import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/services/isar_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/pin_helper.dart';
import '../../../../shared/isar_collections/category_collection.dart';
import '../../../../shared/isar_collections/store_collection.dart';
import '../../../../shared/isar_collections/sync_queue_collection.dart';
import '../../../../shared/isar_collections/user_collection.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';

/// SetupWizardScreen — 2-step wizard for first-time store setup.
/// Step 1: Add first cashier. Step 2: Add first category.
class SetupWizardScreen extends StatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen> {
  int _currentStep = 1;
  bool _isLoading = false;

  // Step 1 — Cashier
  final _step1Key = GlobalKey<FormState>();
  final _cashierNameCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();

  // Step 2 — Category
  final _step2Key = GlobalKey<FormState>();
  final _catNameCtrl = TextEditingController();
  final _catDescCtrl = TextEditingController();

  @override
  void dispose() {
    _cashierNameCtrl.dispose();
    _pinCtrl.dispose();
    _confirmPinCtrl.dispose();
    _catNameCtrl.dispose();
    _catDescCtrl.dispose();
    super.dispose();
  }

  Future<StoreCollection?> _getStore() async {
    return await IsarService.instance.isar.storeCollections
        .filter()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  SyncQueueCollection _syncEntry(
      String table, String syncId, Map<String, dynamic> payload) {
    return SyncQueueCollection()
      ..operationId =
          '${table}_${syncId}_${DateTime.now().millisecondsSinceEpoch}'
      ..tableName = table
      ..recordSyncId = syncId
      ..operation = 'insert'
      ..payloadJson = jsonEncode(payload)
      ..status = 'pending'
      ..retryCount = 0
      ..maxRetries = 3
      ..createdAt = DateTime.now();
  }

  Future<void> _nextStep() async {
    if (!_step1Key.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final store = await _getStore();
    if (store == null) return;

    final syncId = const Uuid().v4();
    final now = DateTime.now();

    final cashier = UserCollection()
      ..syncId = syncId
      ..storeId = store.syncId
      ..name = _cashierNameCtrl.text.trim()
      ..email = '${syncId.substring(0, 8)}@local.suklipos'
      ..pinHash = PinHelper.hashPin(_pinCtrl.text)
      ..role = 'cashier'
      ..status = 'active'
      ..createdAt = now
      ..updatedAt = now
      ..isSynced = false
      ..isDeleted = false;

    final isar = IsarService.instance.isar;
    await isar.writeTxn(() => isar.userCollections.put(cashier));

    final entry = _syncEntry(SupabaseConstants.usersTable, syncId, {
      'sync_id': syncId,
      'store_id': store.syncId,
      'name': cashier.name,
      'email': cashier.email,
      'pin_hash': cashier.pinHash,
      'role': 'cashier',
      'status': 'active',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'is_deleted': false,
    });
    await isar.writeTxn(() => isar.syncQueueCollections.put(entry));

    setState(() {
      _isLoading = false;
      _currentStep = 2;
    });
  }

  Future<void> _finishSetup() async {
    if (!_step2Key.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final store = await _getStore();
    if (store == null) return;

    final syncId = const Uuid().v4();
    final now = DateTime.now();

    final category = CategoryCollection()
      ..syncId = syncId
      ..storeId = store.syncId
      ..name = _catNameCtrl.text.trim()
      ..description =
          _catDescCtrl.text.trim().isEmpty ? null : _catDescCtrl.text.trim()
      ..sortOrder = 1
      ..isActive = true
      ..createdAt = now
      ..updatedAt = now
      ..isSynced = false
      ..isDeleted = false;

    final isar = IsarService.instance.isar;
    await isar.writeTxn(() => isar.categoryCollections.put(category));

    final entry = _syncEntry(SupabaseConstants.categoriesTable, syncId, {
      'sync_id': syncId,
      'store_id': store.syncId,
      'name': category.name,
      'description': category.description,
      'sort_order': 1,
      'is_active': true,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'is_deleted': false,
    });
    await isar.writeTxn(() => isar.syncQueueCollections.put(entry));

    if (mounted) context.go(RouteConstants.adminHome);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final textSec =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.primaryDark : AppColors.primaryLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Store Setup',
            style: AppTextStyles.h3(context).copyWith(color: Colors.white)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Progress bar ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.lg),
              child: Row(
                children: [
                  _StepDot(
                      step: 1,
                      current: _currentStep,
                      label: 'Add Cashier',
                      accent: accent,
                      textSec: textSec),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: _currentStep >= 2
                          ? accent
                          : (isDark ? AppColors.cardDark : AppColors.cardLight),
                    ),
                  ),
                  _StepDot(
                      step: 2,
                      current: _currentStep,
                      label: 'Add Category',
                      accent: accent,
                      textSec: textSec),
                ],
              ),
            ),

            // ── Step content ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: AnimatedSwitcher(
                  duration: AppDuration.medium,
                  child: _currentStep == 1
                      ? _buildStep1(context, textSec)
                      : _buildStep2(context, textSec),
                ),
              ),
            ),

            // ── Bottom buttons ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  if (_currentStep == 2)
                    Expanded(
                      child: AppSecondaryButton(
                        label: 'Back',
                        onPressed: () => setState(() => _currentStep = 1),
                      ),
                    ),
                  if (_currentStep == 2) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppPrimaryButton(
                      label: _currentStep == 1 ? 'Next' : 'Finish Setup',
                      isLoading: _isLoading,
                      onPressed: _isLoading
                          ? null
                          : (_currentStep == 1 ? _nextStep : _finishSetup),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1(BuildContext context, Color textSec) {
    return Form(
      key: _step1Key,
      child: Column(
        key: const ValueKey('step1'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add your first cashier', style: AppTextStyles.h2(context)),
          Text('Cashiers can take orders and process payments.',
              style: AppTextStyles.bodySecondary(context)),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            child: Column(children: [
              AppTextField(
                controller: _cashierNameCtrl,
                label: 'Cashier Name *',
                prefixIcon:
                    Icon(Icons.person_outline, color: textSec, size: 20),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              Divider(color: textSec.withValues(alpha: 0.1)),
              AppTextField(
                controller: _pinCtrl,
                label: 'PIN (4 digits) *',
                prefixIcon: Icon(Icons.pin_outlined, color: textSec, size: 20),
                keyboardType: TextInputType.number,
                obscureText: true,
                validator: (v) {
                  if (v == null || v.length != 4)
                    return 'PIN must be exactly 4 digits';
                  if (!RegExp(r'^\d{4}$').hasMatch(v))
                    return 'PIN must be digits only';
                  return null;
                },
              ),
              Divider(color: textSec.withValues(alpha: 0.1)),
              AppTextField(
                controller: _confirmPinCtrl,
                label: 'Confirm PIN *',
                prefixIcon: Icon(Icons.pin_outlined, color: textSec, size: 20),
                keyboardType: TextInputType.number,
                obscureText: true,
                validator: (v) =>
                    v != _pinCtrl.text ? 'PINs do not match' : null,
              ),
            ]),
          ).animate().fadeIn(duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildStep2(BuildContext context, Color textSec) {
    return Form(
      key: _step2Key,
      child: Column(
        key: const ValueKey('step2'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add your first category', style: AppTextStyles.h2(context)),
          Text('Categories help organize your menu items.',
              style: AppTextStyles.bodySecondary(context)),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            child: Column(children: [
              AppTextField(
                controller: _catNameCtrl,
                label: 'Category Name *',
                hint: 'e.g. Beverages, Food, Snacks',
                prefixIcon:
                    Icon(Icons.category_outlined, color: textSec, size: 20),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Category name is required'
                    : null,
              ),
              Divider(color: textSec.withValues(alpha: 0.1)),
              AppTextField(
                controller: _catDescCtrl,
                label: 'Description (optional)',
                prefixIcon: Icon(Icons.notes_rounded, color: textSec, size: 20),
              ),
            ]),
          ).animate().fadeIn(duration: 400.ms),
        ],
      ),
    );
  }
}

/// Circular step indicator dot.
class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.step,
    required this.current,
    required this.label,
    required this.accent,
    required this.textSec,
  });

  final int step;
  final int current;
  final String label;
  final Color accent;
  final Color textSec;

  @override
  Widget build(BuildContext context) {
    final isCompleted = step < current;
    final isActive = step == current;

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: (isCompleted || isActive)
                ? accent
                : (Theme.of(context).brightness == Brightness.dark
                    ? AppColors.cardDark
                    : AppColors.cardLight),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : Text(
                  '$step',
                  style: AppTextStyles.captionMedium(context).copyWith(
                    color: isActive ? Colors.white : textSec,
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption(context).copyWith(
            color: isActive ? accent : textSec,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
