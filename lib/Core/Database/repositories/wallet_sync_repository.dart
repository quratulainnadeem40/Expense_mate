import 'package:drift/drift.dart';

import '../app_database.dart';
import 'sync_queue_repository.dart';
import 'wallet_local_repository.dart';

class WalletSyncRepository {
  final WalletLocalRepository localRepository;
  final SyncQueueRepository syncQueue;

  WalletSyncRepository({
    required this.localRepository,
    required this.syncQueue,
  });

  // ---------------------------------------------------------------------------
  // CREATE WALLET
  // ---------------------------------------------------------------------------

  Future<void> createWallet({
    required String userId,
    required String id,
    required String name,
    required double balance,
    required String currency,
    required String type,
    DateTime? createdAt,
  }) async {
    final now = DateTime.now();
    final created = createdAt ?? now;

    final wallet = LocalWalletsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      balance: Value(balance),
      currency: Value(currency),
      type: Value(type),
      createdAt: Value(created),
      updatedAt: Value(now),
      version: const Value(1),
      isDeleted: const Value(false),
    );

    // Save locally first.
    await localRepository.insertWallet(wallet);

    // Add operation to sync queue.
    await syncQueue.enqueue(
      userId: userId,
      entityTable: 'wallets',
      recordId: id,
      operation: 'insert',
      payload: {
        'id': id,
        'user_id': userId,
        'name': name,
        'balance': balance,
        'currency': currency,
        'type': type,
        'created_at': created.toIso8601String(),
      },
    );
  }

  // ---------------------------------------------------------------------------
  // UPDATE WALLET
  // ---------------------------------------------------------------------------

  Future<void> updateWallet({
    required String userId,
    required String id,
    required String name,
    required double balance,
    required String currency,
    required String type,
    required DateTime createdAt,
  }) async {
    final now = DateTime.now();

    final wallet = LocalWalletsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      balance: Value(balance),
      currency: Value(currency),
      type: Value(type),
      createdAt: Value(createdAt),
      updatedAt: Value(now),
      version: const Value(1),
      isDeleted: const Value(false),
    );

    // Update local database immediately.
    await localRepository.updateWallet(
      id,
      wallet,
    );

    // Queue cloud synchronization.
    await syncQueue.enqueue(
      userId: userId,
      entityTable: 'wallets',
      recordId: id,
      operation: 'update',
      payload: {
        'id': id,
        'user_id': userId,
        'name': name,
        'balance': balance,
        'currency': currency,
        'type': type,
        'created_at': createdAt.toIso8601String(),
      },
    );
  }

  // ---------------------------------------------------------------------------
  // DELETE WALLET
  // ---------------------------------------------------------------------------

  Future<void> deleteWallet({
    required String userId,
    required String id,
  }) async {
    // Soft delete locally first.
    await localRepository.softDeleteWallet(id);

    // Queue cloud deletion.
    await syncQueue.enqueue(
      userId: userId,
      entityTable: 'wallets',
      recordId: id,
      operation: 'delete',
      payload: {
        'id': id,
      },
    );
  }
}