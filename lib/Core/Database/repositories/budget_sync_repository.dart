import 'package:drift/drift.dart';

import '../app_database.dart';
import 'budget_local_repository.dart';
import 'sync_queue_repository.dart';

class BudgetSyncRepository {
  final BudgetLocalRepository localRepository;
  final SyncQueueRepository syncQueue;

  BudgetSyncRepository({
    required this.localRepository,
    required this.syncQueue,
  });

  /// Create a budget locally and add it to the sync queue.
  Future<void> createBudget({
    required String id,
    required String userId,
    String? categoryId,
    required String name,
    required double amount,
    double spent = 0.0,
    required DateTime startDate,
    required DateTime endDate,
    DateTime? createdAt,
  }) async {
    final now = DateTime.now();
    final created = createdAt ?? now;

    final budget = LocalBudgetsCompanion(
      id: Value(id),
      userId: Value(userId),
      categoryId: categoryId == null
          ? const Value.absent()
          : Value(categoryId),
      name: Value(name),
      amount: Value(amount),
      spent: Value(spent),
      startDate: Value(startDate),
      endDate: Value(endDate),
      createdAt: Value(created),
      updatedAt: Value(now),
      version: const Value(1),
      isDeleted: const Value(false),
    );

    await localRepository.insertBudget(budget);

    await syncQueue.enqueue(
      userId: userId,
      entityTable: 'budgets',
      recordId: id,
      operation: 'insert',
      payload: {
        'id': id,
        'user_id': userId,
        'category_id': categoryId,
        'name': name,
        'amount': amount,
        'spent': spent,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'created_at': created.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'version': 1,
      },
    );
  }

  /// Update a budget locally and add the update to the sync queue.
  Future<void> updateBudget({
    required String id,
    required String userId,
    String? categoryId,
    required String name,
    required double amount,
    double spent = 0.0,
    required DateTime startDate,
    required DateTime endDate,
    DateTime? createdAt,
    int version = 1,
  }) async {
    final now = DateTime.now();
    final created = createdAt ?? now;

    final budget = LocalBudgetsCompanion(
      userId: Value(userId),
      categoryId: categoryId == null
          ? const Value.absent()
          : Value(categoryId),
      name: Value(name),
      amount: Value(amount),
      spent: Value(spent),
      startDate: Value(startDate),
      endDate: Value(endDate),
      createdAt: Value(created),
      updatedAt: Value(now),
      version: Value(version + 1),
      isDeleted: const Value(false),
    );

    await localRepository.updateBudget(id, budget);

    await syncQueue.enqueue(
      userId: userId,
      entityTable: 'budgets',
      recordId: id,
      operation: 'update',
      payload: {
        'id': id,
        'user_id': userId,
        'category_id': categoryId,
        'name': name,
        'amount': amount,
        'spent': spent,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'created_at': created.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'version': version + 1,
      },
    );
  }

  /// Delete a budget locally and add the delete operation to the queue.
  Future<void> deleteBudget({
    required String userId,
    required String id,
  }) async {
    await localRepository.softDeleteBudget(id);

    await syncQueue.enqueue(
      userId: userId,
      entityTable: 'budgets',
      recordId: id,
      operation: 'delete',
      payload: {
        'id': id,
      },
    );
  }

  /// Permanently remove a budget from local storage.
  Future<void> permanentlyDeleteBudget(String id) async {
    await localRepository.permanentDeleteBudget(id);
  }
}