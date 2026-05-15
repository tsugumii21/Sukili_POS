import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import '../../core/services/isar_service.dart';

/// Provider exposing the initialized IsarService singleton.
final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService.instance;
});

/// Convenience provider for the Isar instance directly.
final isarProvider = Provider<Isar>((ref) {
  return ref.watch(isarServiceProvider).isar;
});
