import 'package:drift/drift.dart';

import '../app_database.dart';
import 'sync_queue_repository.dart';
import 'transaction_local_repository.dart';

class TransactionSyncRepository {
  final TransactionLocalRepository localRepository;
  final SyncQueueRepository syncQueue;

  TransactionSyncRepository({
    required this.localRepository,
    required this.syncQueue,
  });

  Future<void> createTransaction({
    required String userId,
    required String id,
    required String walletId,
    required String categoryId,
    required String title,
    required double amount,
    required String type,
    required DateTime transactionDate,
    String? note,
    DateTime? createdAt,
  }) async {
    final now = DateTime.now();
    final created = createdAt ?? now;

    final transaction = LocalTransactionsCompanion(
      id: Value(id),
      userId: Value(userId),
      walletId: _nullableValue(walletId),
      categoryId: _nullableValue(categoryId),
      title: Value(title),
      amount: Value(amount),
      type: Value(type),
      transactionDate: Value(transactionDate),
      note: _nullableValue(note),
      createdAt: Value(created),
      updatedAt: Value(now),
      version: const Value(1),
      isDeleted: const Value(false),
    );

    await localRepository.insertTransaction(transaction);

    await syncQueue.enqueue(
      userId: userId,
      entityTable: 'transactions',
      recordId: id,
      operation: 'insert',
      payload: {
        'id': id,
        'user_id': userId,
        'wallet_id': walletId.isEmpty ? null : walletId,
        'category_id': categoryId.isEmpty ? null : categoryId,
        'title': title,
        'amount': amount,
        'type': type,
        'transaction_date':
            transactionDate.toIso8601String(),
        'note': note,
        'created_at': created.toIso8601String(),
      },
    );
  }

  Future<void> updateTransaction({
    required String userId,
    required String id,
    required String walletId,
    required String categoryId,
    required String title,
    required double amount,
    required String type,
    required DateTime transactionDate,
    String? note,
    required DateTime createdAt,
  }) async {
    final now = DateTime.now();

    final transaction = LocalTransactionsCompanion(
      id: Value(id),
      userId: Value(userId),
      walletId: _nullableValue(walletId),
      categoryId: _nullableValue(categoryId),
      title: Value(title),
      amount: Value(amount),
      type: Value(type),
      transactionDate: Value(transactionDate),
      note: _nullableValue(note),
      createdAt: Value(createdAt),
      updatedAt: Value(now),
      version: const Value(1),
      isDeleted: const Value(false),
    );

    await localRepository.updateTransaction(
      id,
      transaction,
    );

    await syncQueue.enqueue(
      userId: userId,
      entityTable: 'transactions',
      recordId: id,
      operation: 'update',
      payload: {
        'id': id,
        'user_id': userId,
        'wallet_id': walletId.isEmpty ? null : walletId,
        'category_id':
            categoryId.isEmpty ? null : categoryId,
        'title': title,
        'amount': amount,
        'type': type,
        'transaction_date':
            transactionDate.toIso8601String(),
        'note': note,
        'created_at': createdAt.toIso8601String(),
      },
    );
  }

  Future<void> deleteTransaction({
  required String userId,
  required String id,
}) async {
  await localRepository.softDeleteTransaction(id);

  await syncQueue.enqueue(
    userId: userId,
    entityTable: 'transactions',
    recordId: id,
    operation: 'delete',
    payload: {
      'id': id,
    },
  );
}

  Value<String?> _nullableValue(
    String? value,
  ) {
    if (value == null || value.isEmpty) {
      return const Value(null);
    }

    return Value(value);
  }
}