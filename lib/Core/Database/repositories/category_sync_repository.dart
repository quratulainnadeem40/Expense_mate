import 'package:drift/drift.dart';

import '../app_database.dart';
import 'category_local_repository.dart';
import 'sync_queue_repository.dart';

class CategorySyncRepository {
  final CategoryLocalRepository localRepository;
  final SyncQueueRepository syncQueue;

  CategorySyncRepository({
    required this.localRepository,
    required this.syncQueue,
  });

  // ---------------------------------------------------------------------------
  // CREATE CATEGORY
  // ---------------------------------------------------------------------------

  Future<void> createCategory({
    required String userId,
    required String id,
    required String name,
    required String type,
    String? icon,
    String? color,
    DateTime? createdAt,
  }) async {
    final now = DateTime.now();
    final created = createdAt ?? now;

    final category = LocalCategoriesCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      type: Value(type),
      icon: _nullableValue(icon),
      color: _nullableValue(color),
      createdAt: Value(created),
      updatedAt: Value(now),
      version: const Value(1),
      isDeleted: const Value(false),
    );

    // Save locally first.
    await localRepository.insertCategory(category);

    // Add operation to sync queue.
    await syncQueue.enqueue(
      userId: userId,
      entityTable: 'categories',
      recordId: id,
      operation: 'insert',
      payload: {
        'id': id,
        'user_id': userId,
        'name': name,
        'type': type,
        'icon': icon,
        'color': color,
        'created_at': created.toIso8601String(),
      },
    );
  }

  // ---------------------------------------------------------------------------
  // UPDATE CATEGORY
  // ---------------------------------------------------------------------------

  Future<void> updateCategory({
    required String userId,
    required String id,
    required String name,
    required String type,
    String? icon,
    String? color,
    required DateTime createdAt,
  }) async {
    final now = DateTime.now();

    final category = LocalCategoriesCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      type: Value(type),
      icon: _nullableValue(icon),
      color: _nullableValue(color),
      createdAt: Value(createdAt),
      updatedAt: Value(now),
      version: const Value(1),
      isDeleted: const Value(false),
    );

    // Update local database immediately.
    await localRepository.updateCategory(
      id,
      category,
    );

    // Queue cloud synchronization.
    await syncQueue.enqueue(
      userId: userId,
      entityTable: 'categories',
      recordId: id,
      operation: 'update',
      payload: {
        'id': id,
        'user_id': userId,
        'name': name,
        'type': type,
        'icon': icon,
        'color': color,
        'created_at': createdAt.toIso8601String(),
      },
    );
  }

  // ---------------------------------------------------------------------------
  // DELETE CATEGORY
  // ---------------------------------------------------------------------------

  Future<void> deleteCategory({
    required String userId,
    required String id,
  }) async {
    // Soft delete locally first.
    await localRepository.softDeleteCategory(id);

    // Queue cloud deletion.
    await syncQueue.enqueue(
      userId: userId,
      entityTable: 'categories',
      recordId: id,
      operation: 'delete',
      payload: {
        'id': id,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  Value<String?> _nullableValue(
    String? value,
  ) {
    if (value == null || value.isEmpty) {
      return const Value(null);
    }

    return Value(value);
  }
}