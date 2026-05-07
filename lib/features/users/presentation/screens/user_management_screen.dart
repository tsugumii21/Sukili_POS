import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/isar_collections/user_collection.dart';
import '../providers/users_provider.dart';
import '../widgets/user_tile.dart';
import 'user_form_screen.dart';

/// UserManagementScreen — admin view for listing, filtering, searching,
/// adding, editing, and deactivating users.
class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  bool _showSearch = false;
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();

  static const _maroon = Color(0xFF8B4049);

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _showSearch = true);
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  void _closeSearch() {
    setState(() => _showSearch = false);
    _searchCtrl.clear();
    ref.read(usersProvider.notifier).setSearch('');
    FocusScope.of(context).unfocus();
  }

  Future<void> _openForm({UserCollection? user}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => UserFormScreen(user: user),
        fullscreenDialog: true,
      ),
    );
    if (result == true && mounted) {
      ref.read(usersProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: _buildAppBar(context, textPrimary, isDark),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: _maroon,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: Text(
          'Add User',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
      ).animate().slideY(begin: 0.3, end: 0, duration: 400.ms).fadeIn(),
      body: usersAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) =>
            Center(child: Text('Error loading users: $e')),
        data: (state) => Column(
          children: [
            // ── Filter chips ───────────────────────────────────────────
            _FilterChipsRow(
              selected: state.filter,
              onChanged: (f) =>
                  ref.read(usersProvider.notifier).setFilter(f),
            ),
            // ── User list ──────────────────────────────────────────────
            Expanded(
              child: _buildList(
                context,
                state,
                textPrimary,
                isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(
      BuildContext context, Color textPrimary, bool isDark) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: _showSearch
          ? IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
              onPressed: _closeSearch,
            )
          : IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: textPrimary, size: 20),
              onPressed: () => context.pop(),
            ),
      title: _showSearch
          ? TextField(
              controller: _searchCtrl,
              focusNode: _searchFocus,
              style: GoogleFonts.dmSans(
                  color: textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Search by name or email…',
                hintStyle: GoogleFonts.dmSans(
                  color: textPrimary.withValues(alpha: 0.4),
                  fontSize: 15,
                ),
                border: InputBorder.none,
              ),
              onChanged: (q) =>
                  ref.read(usersProvider.notifier).setSearch(q),
            )
          : Text(
              'User Management',
              style: AppTextStyles.bodySemiBold(context),
            ),
      actions: [
        if (!_showSearch)
          IconButton(
            icon: Icon(Icons.search_rounded, color: textPrimary),
            onPressed: _openSearch,
          ),
        if (!_showSearch) const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildList(
    BuildContext context,
    UsersState state,
    Color textPrimary,
    bool isDark,
  ) {
    final users = state.filtered;

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline_rounded,
                size: 64,
                color: textPrimary.withValues(alpha: 0.2)),
            const SizedBox(height: AppSpacing.md),
            Text(
              state.searchQuery.isNotEmpty
                  ? 'No users match "${state.searchQuery}"'
                  : 'No users found.',
              style: AppTextStyles.bodySecondary(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(usersProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xxl + 80, // extra space for FAB
        ),
        itemCount: users.length,
        itemBuilder: (_, i) => UserTile(
          user: users[i],
          animationIndex: i,
          onTap: () => _openForm(user: users[i]),
        ),
      ),
    );
  }
}

// ── Filter Chips Row ──────────────────────────────────────────────────────────

class _FilterChipsRow extends StatelessWidget {
  const _FilterChipsRow({
    required this.selected,
    required this.onChanged,
  });

  final UsersFilter selected;
  final ValueChanged<UsersFilter> onChanged;

  static const _filters = [
    (UsersFilter.all, 'All'),
    (UsersFilter.cashiers, 'Cashiers'),
    (UsersFilter.admins, 'Admins'),
    (UsersFilter.active, 'Active'),
    (UsersFilter.inactive, 'Inactive'),
  ];

  static const _maroon = Color(0xFF8B4049);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: 4),
        children: _filters.map((entry) {
          final (filter, label) = entry;
          final isSelected = selected == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _maroon
                      : (isDark
                          ? AppColors.cardDark
                          : AppColors.cardLight),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _maroon.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  label,
                  style: GoogleFonts.dmSans(
                    color: isSelected
                        ? Colors.white
                        : textPrimary.withValues(alpha: 0.65),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
