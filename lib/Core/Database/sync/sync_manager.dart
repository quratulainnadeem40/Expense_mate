import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_database.dart';
import '../database_provider.dart';
import '../repositories/category_local_repository.dart';
import '../repositories/sync_queue_repository.dart';
import '../repositories/transaction_local_repository.dart';
import '../repositories/wallet_local_repository.dart';
import '../remote/category_remote_repository.dart';
import '../remote/transaction_remote_repository.dart';
import '../remote/wallet_remote_repository.dart';

class SyncManager {
  final SupabaseClient supabase;

  late final TransactionLocalRepository transactionLocal;
  late final WalletLocalRepository walletLocal;
  late final CategoryLocalRepository categoryLocal;
  late final SyncQueueRepository syncQueue;

  late final TransactionRemoteRepository transactionRemote;
  late final WalletRemoteRepository walletRemote;
  late final CategoryRemoteRepository categoryRemote;

  bool _isSyncing = false;

  SyncManager({
    SupabaseClient? supabaseClient,
  }) : supabase = supabaseClient ?? Supabase.instance.client {
    final database = DatabaseProvider.instance.database;

    transactionLocal = TransactionLocalRepository(database);
    walletLocal = WalletLocalRepository(database);
    categoryLocal = CategoryLocalRepository(database);
    syncQueue = SyncQueueRepository(database);

    transactionRemote = TransactionRemoteRepository(supabase);
    walletRemote = WalletRemoteRepository(supabase);
    categoryRemote = CategoryRemoteRepository(supabase);
  }

  /// Main synchronization entry point.
  ///
  /// 1. Uploads pending local changes.
  /// 2. Downloads cloud data into local SQLite.
  Future<void> sync() async {
    if (_isSyncing) {
      return;
    }

    final user = supabase.auth.currentUser;

    if (user == null) {
      return;
    }

    _isSyncing = true;

    try {
      // First upload all pending local changes.
      await _syncPendingOperations(user.id);

      // Then download the latest cloud data.
      await _syncCloudToLocal(user.id);
    } finally {
      _isSyncing = false;
    }
  }

  /// Upload all pending local operations to Supabase.
  Future<void> _syncPendingOperations(
    String userId,
  ) async {
    final pendingOperations =
        await syncQueue.getPendingOperations(userId);

    for (final queueItem in pendingOperations) {
      try {
        await _processQueueItem(queueItem);
      } catch (e) {
        final nextRetryCount = queueItem.retryCount + 1;

        await syncQueue.updateRetryInfo(
          id: queueItem.id,
          retryCount: nextRetryCount,
          lastError: e.toString(),
        );
      }
    }
  }

  Future<void> _processQueueItem(
    SyncQueueData queueItem,
  ) async {
    final payload = _decodePayload(queueItem.payload);

    switch (queueItem.entityTable) {
      case 'transactions':
        await _syncTransaction(
          queueItem: queueItem,
          payload: payload,
        );
        break;

      case 'wallets':
        await _syncWallet(
          queueItem: queueItem,
          payload: payload,
        );
        break;

      case 'categories':
        await _syncCategory(
          queueItem: queueItem,
          payload: payload,
        );
        break;

      default:
        throw Exception(
          'Unknown sync entity: ${queueItem.entityTable}',
        );
    }
  }

  // ---------------------------------------------------------------------------
  // TRANSACTION SYNC
  // ---------------------------------------------------------------------------

  Future<void> _syncTransaction({
    required SyncQueueData queueItem,
    required Map<String, dynamic> payload,
  }) async {
    switch (queueItem.operation.toLowerCase()) {
      case 'insert':
      case 'create':
        await transactionRemote.insertTransaction(payload);

        await syncQueue.remove(queueItem.id);
        break;

      case 'update':
        await transactionRemote.updateTransaction(
          queueItem.recordId,
          payload,
        );

        await syncQueue.remove(queueItem.id);
        break;

      case 'delete':
        await transactionRemote.deleteTransaction(
          queueItem.recordId,
        );

        await transactionLocal.permanentlyDeleteTransaction(
          queueItem.recordId,
        );

        await syncQueue.remove(queueItem.id);
        break;

      default:
        throw Exception(
          'Unknown transaction operation: '
          '${queueItem.operation}',
        );
    }
  }

  // ---------------------------------------------------------------------------
  // WALLET SYNC
  // ---------------------------------------------------------------------------

  Future<void> _syncWallet({
    required SyncQueueData queueItem,
    required Map<String, dynamic> payload,
  }) async {
    switch (queueItem.operation.toLowerCase()) {
      case 'insert':
      case 'create':
        await walletRemote.insertWallet(payload);

        await syncQueue.remove(queueItem.id);
        break;

      case 'update':
        await walletRemote.updateWallet(
          queueItem.recordId,
          payload,
        );

        await syncQueue.remove(queueItem.id);
        break;

      case 'delete':
        await walletRemote.deleteWallet(
          queueItem.recordId,
        );

        await walletLocal.permanentlyDeleteWallet(
          queueItem.recordId,
        );

        await syncQueue.remove(queueItem.id);
        break;

      default:
        throw Exception(
          'Unknown wallet operation: '
          '${queueItem.operation}',
        );
    }
  }

  // ---------------------------------------------------------------------------
  // CATEGORY SYNC
  // ---------------------------------------------------------------------------

  Future<void> _syncCategory({
    required SyncQueueData queueItem,
    required Map<String, dynamic> payload,
  }) async {
    switch (queueItem.operation.toLowerCase()) {
      case 'insert':
      case 'create':
        await categoryRemote.insertCategory(payload);

        await syncQueue.remove(queueItem.id);
        break;

      case 'update':
        await categoryRemote.updateCategory(
          queueItem.recordId,
          payload,
        );

        await syncQueue.remove(queueItem.id);
        break;

      case 'delete':
        await categoryRemote.deleteCategory(
          queueItem.recordId,
        );

        await categoryLocal.permanentlyDeleteCategory(
          queueItem.recordId,
        );

        await syncQueue.remove(queueItem.id);
        break;

      default:
        throw Exception(
          'Unknown category operation: '
          '${queueItem.operation}',
        );
    }
  }

  // ---------------------------------------------------------------------------
  // CLOUD → LOCAL
  // ---------------------------------------------------------------------------

  Future<void> _syncCloudToLocal(
    String userId,
  ) async {
    await _syncTransactionsFromCloud(userId);
    await _syncWalletsFromCloud(userId);
    await _syncCategoriesFromCloud(userId);
  }

  // ---------------------------------------------------------------------------
  // TRANSACTIONS: CLOUD → LOCAL
  // ---------------------------------------------------------------------------

  Future<void> _syncTransactionsFromCloud(
    String userId,
  ) async {
    final transactions =
        await transactionRemote.getTransactions(userId);

    for (final transaction in transactions) {
      final id = transaction['id']?.toString();

      if (id == null || id.isEmpty) {
        continue;
      }

      // Do not overwrite a local record that still has
      // a pending local operation.
      final pending = await syncQueue.getByEntityAndRecord(
        userId: userId,
        entityTable: 'transactions',
        recordId: id,
      );

      if (pending != null) {
        continue;
      }

      final existing =
          await transactionLocal.getTransactionById(id);

      final transactionDate =
          _parseDate(transaction['transaction_date']);

      final createdAt =
          _parseDate(transaction['created_at']);

      final companion = LocalTransactionsCompanion(
        id: Value(id),
        userId: Value(userId),
        walletId: _nullableValue(
          transaction['wallet_id'],
        ),
        categoryId: _nullableValue(
          transaction['category_id'],
        ),
        title: Value(
          transaction['title']?.toString() ?? '',
        ),
        amount: Value(
          (transaction['amount'] as num?)?.toDouble() ?? 0.0,
        ),
        type: Value(
          transaction['type']?.toString() ?? 'expense',
        ),
        transactionDate: Value(transactionDate),
        note: _nullableValue(
          transaction['note'],
        ),
        createdAt: Value(createdAt),
        updatedAt: Value(DateTime.now()),
        version: const Value(1),
        isDeleted: const Value(false),
      );

      if (existing == null) {
        await transactionLocal.insertTransaction(
          companion,
        );
      } else {
        await transactionLocal.updateTransaction(
          id,
          companion,
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // WALLETS: CLOUD → LOCAL
  // ---------------------------------------------------------------------------

  Future<void> _syncWalletsFromCloud(
    String userId,
  ) async {
    final wallets = await walletRemote.getWallets(userId);

    for (final wallet in wallets) {
      final id = wallet['id']?.toString();

      if (id == null || id.isEmpty) {
        continue;
      }

      // Do not overwrite a local record that still has
      // a pending local operation.
      final pending = await syncQueue.getByEntityAndRecord(
        userId: userId,
        entityTable: 'wallets',
        recordId: id,
      );

      if (pending != null) {
        continue;
      }

      final existing =
          await walletLocal.getWalletById(id);

      final createdAt =
          _parseDate(wallet['created_at']);

      final companion = LocalWalletsCompanion(
        id: Value(id),
        userId: Value(userId),
        name: Value(
          wallet['name']?.toString() ?? '',
        ),
        balance: Value(
          (wallet['balance'] as num?)?.toDouble() ?? 0.0,
        ),
        currency: Value(
          wallet['currency']?.toString() ?? 'PKR',
        ),
        type: Value(
          wallet['type']?.toString() ?? 'Cash',
        ),
        createdAt: Value(createdAt),
        updatedAt: Value(DateTime.now()),
        version: const Value(1),
        isDeleted: const Value(false),
      );

      if (existing == null) {
        await walletLocal.insertWallet(
          companion,
        );
      } else {
        await walletLocal.updateWallet(
          id,
          companion,
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // CATEGORIES: CLOUD → LOCAL
  // ---------------------------------------------------------------------------

  Future<void> _syncCategoriesFromCloud(
    String userId,
  ) async {
    final categories =
        await categoryRemote.getCategories(userId);

    for (final category in categories) {
      final id = category['id']?.toString();

      if (id == null || id.isEmpty) {
        continue;
      }

      // Do not overwrite a local record that still has
      // a pending local operation.
      final pending = await syncQueue.getByEntityAndRecord(
        userId: userId,
        entityTable: 'categories',
        recordId: id,
      );

      if (pending != null) {
        continue;
      }

      final existing =
          await categoryLocal.getCategoryById(id);

      final createdAt =
          _parseDate(category['created_at']);

      final companion = LocalCategoriesCompanion(
        id: Value(id),
        userId: Value(userId),
        name: Value(
          category['name']?.toString() ?? '',
        ),
        type: Value(
          category['type']?.toString() ?? 'expense',
        ),
        icon: _nullableValue(
          category['icon'],
        ),
        color: _nullableValue(
          category['color'],
        ),
        createdAt: Value(createdAt),
        updatedAt: Value(DateTime.now()),
        version: const Value(1),
        isDeleted: const Value(false),
      );

      if (existing == null) {
        await categoryLocal.insertCategory(
          companion,
        );
      } else {
        await categoryLocal.updateCategory(
          id,
          companion,
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _decodePayload(
    String payload,
  ) {
    final decoded = jsonDecode(payload);

    if (decoded is! Map) {
      throw const FormatException(
        'Sync payload must be a JSON object.',
      );
    }

    return Map<String, dynamic>.from(decoded);
  }

  DateTime _parseDate(
    dynamic value,
  ) {
    if (value == null) {
      return DateTime.now();
    }

    return DateTime.tryParse(
          value.toString(),
        ) ??
        DateTime.now();
  }

  Value<String?> _nullableValue(
    dynamic value,
  ) {
    if (value == null) {
      return const Value(null);
    }

    final stringValue = value.toString();

    if (stringValue.isEmpty) {
      return const Value(null);
    }

    return Value(stringValue);
  }

  bool get isSyncing => _isSyncing;
}