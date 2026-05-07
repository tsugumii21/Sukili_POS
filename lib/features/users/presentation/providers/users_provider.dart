import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/services/isar_service.dart';
import '../../../../core/services/sync_service.dart';
import '../../../../core/utils/pin_helper.dart';
import '../../../../shared/isar_collections/user_collection.dart';

/// Filter options for the user list.
enum UsersFilter { all, cashiers, admins, active, inactive }

/// UsersState holds the full user list plus the current filter/search state.
class UsersState {
  final List<UserCollection> allUsers;
  final UsersFilter filter;
  final String searchQuery;

  const UsersState({
    required this.allUsers,
    this.filter = UsersFilter.all,
    this.searchQuery = '',
  });

  UsersState copyWith({
    List<UserCollection>? allUsers,
    UsersFilter? filter,
    String? searchQuery,
  }) =>
      UsersState(
        allUsers: allUsers ?? this.allUsers,
        filter: filter ?? this.filter,
        searchQuery: searchQuery ?? this.searchQuery,
      );

  /// Returns users with current filter + search applied.
  List<UserCollection> get filtered {
    var result = allUsers;

    switch (filter) {
      case UsersFilter.cashiers:
        result = result.where((u) => u.role == 'cashier').toList();
        break;
      case UsersFilter.admins:
        result = result.where((u) => u.role == 'admin').toList();
        break;
      case UsersFilter.active:
        result = result.where((u) => u.status == 'active').toList();
        break;
      case UsersFilter.inactive:
        result = result.where((u) => u.status == 'inactive').toList();
        break;
      case UsersFilter.all:
        break;
    }

    final q = searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result
          .where((u) =>
              u.name.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q))
          .toList();
    }

    return result;
  }
}

/// UsersNotifier manages CRUD operations for users via Isar + SyncQueue.
class UsersNotifier extends Notifier<AsyncValue<UsersState>> {
  static const _uuid = Uuid();

  @override
  AsyncValue<UsersState> build() {
    _init();
    return const AsyncValue.loading();
  }

  IsarService get _isar => IsarService.instance;

  void _init() {
    Future.microtask(_loadUsers);
    _isar.isar.userCollections.watchLazy().listen((_) => _loadUsers());
  }

  // ── Data Loading ────────────────────────────────────────────────────────────

  Future<void> _loadUsers() async {
    try {
      final current = state.asData?.value;
      // Filter by cashier role (indexed) + isDeleted check in Dart,
      // then a second pass for admins. isDeleted is not indexed.
      final cashiers = await _isar.isar.userCollections
          .filter()
          .roleEqualTo('cashier')
          .findAll();
      final admins = await _isar.isar.userCollections
          .filter()
          .roleEqualTo('admin')
          .findAll();
      final users = [...cashiers, ...admins]
          .where((u) => !u.isDeleted)
          .toList();
      users.sort((a, b) => a.name.compareTo(b.name));
      state = AsyncValue.data(UsersState(
        allUsers: users,
        filter: current?.filter ?? UsersFilter.all,
        searchQuery: current?.searchQuery ?? '',
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _loadUsers();

  // ── Filter / Search ─────────────────────────────────────────────────────────

  void setFilter(UsersFilter filter) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(filter: filter));
  }

  void setSearch(String query) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(searchQuery: query));
  }

  // ── Create ──────────────────────────────────────────────────────────────────

  Future<void> createUser({
    required String name,
    required String email,
    required String role,
    String? pin,
    String status = 'active',
  }) async {
    final now = DateTime.now();
    final syncId = _uuid.v4();
    final user = UserCollection()
      ..syncId = syncId
      ..name = name.trim()
      ..email = email.trim().toLowerCase()
      ..role = role
      ..status = status
      ..pinHash = (role == 'cashier' && pin != null && pin.length == 4)
          ? PinHelper.hashPin(pin)
          : null
      ..createdAt = now
      ..updatedAt = now
      ..isSynced = false
      ..isDeleted = false;

    await _isar.isar.writeTxn(() async {
      await _isar.isar.userCollections.put(user);
    });
    await SyncService.instance.addToQueue(
      tableName: SupabaseConstants.usersTable,
      recordSyncId: syncId,
      operation: 'insert',
      payload: _toPayload(user),
    );
  }

  // ── Update ──────────────────────────────────────────────────────────────────

  Future<void> updateUser({
    required UserCollection user,
    required String name,
    required String email,
    required String role,
    required String status,
    String? newPin,
  }) async {
    final now = DateTime.now();
    user
      ..name = name.trim()
      ..email = email.trim().toLowerCase()
      ..role = role
      ..status = status
      ..updatedAt = now
      ..isSynced = false;

    if (role == 'cashier' && newPin != null && newPin.length == 4) {
      user.pinHash = PinHelper.hashPin(newPin);
    }

    await _isar.isar.writeTxn(() async {
      await _isar.isar.userCollections.put(user);
    });
    await SyncService.instance.addToQueue(
      tableName: SupabaseConstants.usersTable,
      recordSyncId: user.syncId,
      operation: 'update',
      payload: _toPayload(user),
    );
  }

  // ── Toggle Status ───────────────────────────────────────────────────────────

  Future<void> toggleStatus(UserCollection user) async {
    final now = DateTime.now();
    user
      ..status = user.status == 'active' ? 'inactive' : 'active'
      ..updatedAt = now
      ..isSynced = false;

    await _isar.isar.writeTxn(() async {
      await _isar.isar.userCollections.put(user);
    });
    await SyncService.instance.addToQueue(
      tableName: SupabaseConstants.usersTable,
      recordSyncId: user.syncId,
      operation: 'update',
      payload: _toPayload(user),
    );
  }

  // ── Reset PIN ───────────────────────────────────────────────────────────────

  Future<void> resetPin(UserCollection user, String newPin) async {
    final now = DateTime.now();
    user
      ..pinHash = PinHelper.hashPin(newPin)
      ..updatedAt = now
      ..isSynced = false;

    await _isar.isar.writeTxn(() async {
      await _isar.isar.userCollections.put(user);
    });
    await SyncService.instance.addToQueue(
      tableName: SupabaseConstants.usersTable,
      recordSyncId: user.syncId,
      operation: 'update',
      payload: _toPayload(user),
    );
  }

  // ── Soft Delete ─────────────────────────────────────────────────────────────

  Future<void> softDelete(UserCollection user) async {
    final now = DateTime.now();
    user
      ..isDeleted = true
      ..updatedAt = now
      ..isSynced = false;

    await _isar.isar.writeTxn(() async {
      await _isar.isar.userCollections.put(user);
    });
    await SyncService.instance.addToQueue(
      tableName: SupabaseConstants.usersTable,
      recordSyncId: user.syncId,
      operation: 'delete',
      payload: _toPayload(user),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Map<String, dynamic> _toPayload(UserCollection u) => {
        'sync_id': u.syncId,
        'name': u.name,
        'email': u.email,
        'pin_hash': u.pinHash,
        'role': u.role,
        'status': u.status,
        'avatar_url': u.avatarUrl,
        'is_deleted': u.isDeleted,
        'created_at': u.createdAt.toIso8601String(),
        'updated_at': u.updatedAt.toIso8601String(),
      };
}

/// Provider for the User Management data.
final usersProvider =
    NotifierProvider<UsersNotifier, AsyncValue<UsersState>>(
  UsersNotifier.new,
);
