import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_database.dart';
import '../database_provider.dart';

import '../repositories/budget_local_repository.dart';
import '../repositories/budget_remote_repository.dart';
import '../repositories/category_local_repository.dart';
import '../repositories/sync_queue_repository.dart';
import '../repositories/transaction_local_repository.dart';
import '../repositories/wallet_local_repository.dart';

import '../remote/category_remote_repository.dart';
import '../remote/transaction_remote_repository.dart';
import '../remote/wallet_remote_repository.dart';

class SyncManager extends GetxController {
  final SupabaseClient supabase;

  late final TransactionLocalRepository transactionLocal;
  late final WalletLocalRepository walletLocal;
  late final CategoryLocalRepository categoryLocal;
  late final BudgetLocalRepository budgetLocal;
  late final SyncQueueRepository syncQueue;

  late final TransactionRemoteRepository transactionRemote;
  late final WalletRemoteRepository walletRemote;
  late final CategoryRemoteRepository categoryRemote;
  late final BudgetRemoteRepository budgetRemote;

  bool _isSyncing = false;

  Timer? _retryTimer;

  // ==========================================================
  // SYNC STATUS
  // ==========================================================

  final RxString syncStatus = 'Synced'.obs;

  final RxInt pendingCount = 0.obs;

  final RxString lastError = ''.obs;

  DateTime? _lastSuccessfulSync;

  DateTime? get lastSuccessfulSync => _lastSuccessfulSync;

  bool get isSyncing => _isSyncing;

  bool get hasPendingChanges => pendingCount.value > 0;

  bool get hasSyncError => lastError.value.isNotEmpty;

  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================

  SyncManager({
    SupabaseClient? supabaseClient,
  }) : supabase = supabaseClient ?? Supabase.instance.client {
    final database = DatabaseProvider.instance.database;

    transactionLocal = TransactionLocalRepository(database);
    walletLocal = WalletLocalRepository(database);
    categoryLocal = CategoryLocalRepository(database);
    budgetLocal = BudgetLocalRepository(database);
    syncQueue = SyncQueueRepository(database);

    transactionRemote = TransactionRemoteRepository(supabase);
    walletRemote = WalletRemoteRepository(supabase);
    categoryRemote = CategoryRemoteRepository(supabase);
    budgetRemote = BudgetRemoteRepository(supabase);
  }

  // ==========================================================
  // LIFECYCLE
  // ==========================================================

  @override
  void onInit() {
    super.onInit();

    _startAutomaticRetry();
  }

  @override
  void onClose() {
    _retryTimer?.cancel();
    _retryTimer = null;

    super.onClose();
  }

  // ==========================================================
  // AUTOMATIC RETRY
  // ==========================================================

  void _startAutomaticRetry() {
    _retryTimer?.cancel();

    _retryTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) async {
        if (_isSyncing) {
          return;
        }

        final user = supabase.auth.currentUser;

        if (user == null) {
          return;
        }

        await _refreshPendingCount(user.id);

        if (pendingCount.value == 0) {
          return;
        }

        try {
          debugPrint('================================');
          debugPrint('AUTOMATIC SYNC RETRY');
          debugPrint('Pending: ${pendingCount.value}');
          debugPrint('================================');

          await sync();
        } catch (e) {
          debugPrint(
            'Automatic sync retry failed: $e',
          );
        }
      },
    );
  }

  // ==========================================================
  // MAIN SYNC
  // ==========================================================

  Future<void> sync() async {
    if (_isSyncing) {
      return;
    }

    final user = supabase.auth.currentUser;

    if (user == null) {
      syncStatus.value = 'Not signed in';
      pendingCount.value = 0;
      return;
    }

    _isSyncing = true;

    syncStatus.value = 'Syncing...';
    lastError.value = '';

    debugPrint('================================');
    debugPrint('SYNC STARTED');
    debugPrint('User: ${user.id}');
    debugPrint('================================');

    try {
      await _refreshPendingCount(user.id);

      debugPrint(
        'Pending operations: ${pendingCount.value}',
      );

      // ------------------------------------------------------
      // STEP 1: Upload local pending changes.
      // ------------------------------------------------------

      await _syncPendingOperations(user.id);

      // ------------------------------------------------------
      // STEP 2: Download cloud changes.
      // ------------------------------------------------------

      await _syncCloudToLocal(user.id);

      // ------------------------------------------------------
      // STEP 3: Check remaining pending operations.
      // ------------------------------------------------------

      await _refreshPendingCount(user.id);

      if (pendingCount.value == 0) {
        syncStatus.value = 'Synced';

        _lastSuccessfulSync = DateTime.now();

        debugPrint('SYNC SUCCESSFUL');
      } else {
        syncStatus.value = 'Pending';

        debugPrint(
          'SYNC STILL PENDING: ${pendingCount.value}',
        );
      }
    } catch (e, stackTrace) {
      await _refreshPendingCount(user.id);

      syncStatus.value = 'Sync failed';

      lastError.value = e.toString();

      debugPrint('================================');
      debugPrint('SYNC FAILED');
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');
      debugPrint('PENDING: ${pendingCount.value}');
      debugPrint('================================');

      rethrow;
    } finally {
      _isSyncing = false;
    }
  }

  // ==========================================================
  // REFRESH PENDING COUNT
  // ==========================================================

  Future<void> _refreshPendingCount(
    String userId,
  ) async {
    try {
      final operations =
          await syncQueue.getPendingOperations(userId);

      pendingCount.value = operations.length;
    } catch (e) {
      debugPrint(
        'Could not refresh pending count: $e',
      );
    }
  }

  // ==========================================================
  // PENDING OPERATIONS
  // ==========================================================

  Future<void> _syncPendingOperations(
    String userId,
  ) async {
    final pendingOperations =
        await syncQueue.getPendingOperations(userId);

    pendingCount.value = pendingOperations.length;

    debugPrint(
      'Processing ${pendingOperations.length} '
      'pending operation(s)',
    );

    for (final queueItem in pendingOperations) {
      try {
        debugPrint('--------------------------------');
        debugPrint('SYNC QUEUE ITEM');
        debugPrint('ID: ${queueItem.id}');
        debugPrint('Entity: ${queueItem.entityTable}');
        debugPrint('Record: ${queueItem.recordId}');
        debugPrint('Operation: ${queueItem.operation}');

        await _processQueueItem(queueItem);

        if (pendingCount.value > 0) {
          pendingCount.value--;
        }

        debugPrint('QUEUE ITEM SYNCED');
      } catch (e, stackTrace) {
        final nextRetryCount =
            queueItem.retryCount + 1;

        final errorMessage = e.toString();

        await syncQueue.updateRetryInfo(
          id: queueItem.id,
          retryCount: nextRetryCount,
          lastError: errorMessage,
        );

        lastError.value = errorMessage;
        syncStatus.value = 'Sync failed';

        debugPrint('--------------------------------');
        debugPrint('QUEUE ITEM FAILED');
        debugPrint(
          'Entity: ${queueItem.entityTable}',
        );
        debugPrint(
          'Record: ${queueItem.recordId}',
        );
        debugPrint(
          'Operation: ${queueItem.operation}',
        );
        debugPrint(
          'Retry count: $nextRetryCount',
        );
        debugPrint(
          'ERROR: $errorMessage',
        );
        debugPrint(
          'STACK TRACE: $stackTrace',
        );
        debugPrint('--------------------------------');
      }
    }

    await _refreshPendingCount(userId);
  }

  // ==========================================================
  // PROCESS QUEUE ITEM
  // ==========================================================

  Future<void> _processQueueItem(
    SyncQueueData queueItem,
  ) async {
    final payload =
        _decodePayload(queueItem.payload);

    debugPrint('Payload: $payload');

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

      case 'budgets':
        await _syncBudget(
          queueItem: queueItem,
          payload: _cleanBudgetPayload(payload),
        );
        break;

      default:
        throw Exception(
          'Unknown sync entity: '
          '${queueItem.entityTable}',
        );
    }
  }

  // ==========================================================
  // TRANSACTION SYNC
  // ==========================================================

  Future<void> _syncTransaction({
    required SyncQueueData queueItem,
    required Map<String, dynamic> payload,
  }) async {
    switch (queueItem.operation.toLowerCase()) {
      case 'insert':
      case 'create':
        await transactionRemote.insertTransaction(
          payload,
        );

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

        await transactionLocal
            .permanentlyDeleteTransaction(
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

  // ==========================================================
  // WALLET SYNC
  // ==========================================================

  Future<void> _syncWallet({
    required SyncQueueData queueItem,
    required Map<String, dynamic> payload,
  }) async {
    switch (queueItem.operation.toLowerCase()) {
      case 'insert':
      case 'create':
        await walletRemote.insertWallet(
          payload,
        );

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

  // ==========================================================
  // CATEGORY SYNC
  // ==========================================================

  Future<void> _syncCategory({
    required SyncQueueData queueItem,
    required Map<String, dynamic> payload,
  }) async {
    switch (queueItem.operation.toLowerCase()) {
      case 'insert':
      case 'create':
        await categoryRemote.insertCategory(
          payload,
        );

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

        await categoryLocal
            .permanentlyDeleteCategory(
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

  // ==========================================================
  // ENSURE BUDGET CATEGORY EXISTS
  // ==========================================================

  Future<void> _ensureBudgetCategoryExists(
    Map<String, dynamic> payload,
  ) async {
    final categoryId =
        payload['category_id']?.toString();

    // Total budget does not have a category.
    if (categoryId == null ||
        categoryId.isEmpty) {
      return;
    }

    final userId =
        payload['user_id']?.toString();

    if (userId == null || userId.isEmpty) {
      throw Exception(
        'Budget user_id is missing.',
      );
    }

    debugPrint(
      'Checking budget category: $categoryId',
    );

    // --------------------------------------------------------
    // 1. Check Supabase first.
    // --------------------------------------------------------

    final remoteCategory = await supabase
        .from('categories')
        .select('id')
        .eq('id', categoryId)
        .eq('user_id', userId)
        .maybeSingle();

    if (remoteCategory != null) {
      debugPrint(
        'Budget category already exists in Supabase.',
      );

      return;
    }

    debugPrint(
      'Budget category does not exist in Supabase.',
    );

    // --------------------------------------------------------
    // 2. Check pending category queue.
    // --------------------------------------------------------

    final pendingCategory =
        await syncQueue.getByEntityAndRecord(
      userId: userId,
      entityTable: 'categories',
      recordId: categoryId,
    );

    if (pendingCategory != null) {
      debugPrint(
        'Found pending category operation. '
        'Syncing category before budget...',
      );

      await _processQueueItem(
        pendingCategory,
      );

      // Verify again after category sync.
      final categoryAfterSync =
          await supabase
              .from('categories')
              .select('id')
              .eq('id', categoryId)
              .eq('user_id', userId)
              .maybeSingle();

      if (categoryAfterSync != null) {
        debugPrint(
          'Category successfully synced '
          'before budget.',
        );

        return;
      }
    }

    // --------------------------------------------------------
    // 3. Check local Drift.
    // --------------------------------------------------------

    final localCategory =
        await categoryLocal.getCategoryById(
      categoryId,
    );

    if (localCategory != null &&
        !localCategory.isDeleted) {
      debugPrint(
        'Found category locally. '
        'Uploading it before budget...',
      );

      final categoryPayload = {
        'id': localCategory.id,
        'user_id': localCategory.userId,
        'name': localCategory.name,
        'type': localCategory.type,
        'icon': localCategory.icon,
        'color': localCategory.color,
        'created_at':
            localCategory.createdAt.toIso8601String(),
      };

      await categoryRemote.insertCategory(
        categoryPayload,
      );

      debugPrint(
        'Local category uploaded successfully.',
      );

      return;
    }

    // --------------------------------------------------------
    // 4. Category cannot be found.
    // --------------------------------------------------------

    throw Exception(
      'Cannot sync budget because category '
      '$categoryId does not exist in local '
      'or Supabase data.',
    );
  }

  // ==========================================================
  // BUDGET SYNC
  // ==========================================================

  Future<void> _syncBudget({
    required SyncQueueData queueItem,
    required Map<String, dynamic> payload,
  }) async {
    // A budget with category_id must never be uploaded
    // before that category exists in Supabase.
    await _ensureBudgetCategoryExists(
      payload,
    );

    switch (queueItem.operation.toLowerCase()) {
      case 'insert':
      case 'create':
        debugPrint(
          'Uploading budget to Supabase...',
        );

        await budgetRemote.insertBudget(
          _cleanBudgetPayload(payload),
        );

        await syncQueue.remove(queueItem.id);

        debugPrint(
          'Budget uploaded successfully.',
        );

        break;

      case 'update':
        debugPrint(
          'Updating budget in Supabase...',
        );

        await budgetRemote.updateBudget(
          queueItem.recordId,
          _cleanBudgetPayload(payload),
        );

        await syncQueue.remove(queueItem.id);

        debugPrint(
          'Budget updated successfully.',
        );

        break;

      case 'delete':
        debugPrint(
          'Deleting budget from Supabase...',
        );

        await budgetRemote.deleteBudget(
          queueItem.recordId,
        );

        await budgetLocal.permanentDeleteBudget(
          queueItem.recordId,
        );

        await syncQueue.remove(queueItem.id);

        debugPrint(
          'Budget deleted successfully.',
        );

        break;

      default:
        throw Exception(
          'Unknown budget operation: '
          '${queueItem.operation}',
        );
    }
  }

  // ==========================================================
  // BUDGET PAYLOAD CLEANER
  // ==========================================================

  /// Supabase public.budgets currently contains:
  ///
  /// id
  /// user_id
  /// category_id
  /// name
  /// amount
  /// spent
  /// start_date
  /// end_date
  /// created_at
  ///
  /// Local-only sync fields such as updated_at and version
  /// must NEVER be sent to Supabase.
  Map<String, dynamic> _cleanBudgetPayload(
    Map<String, dynamic> payload,
  ) {
    return {
      'id': payload['id'],
      'user_id': payload['user_id'],
      'category_id': payload['category_id'],
      'name': payload['name'],
      'amount': payload['amount'],
      'spent': payload['spent'],
      'start_date': payload['start_date'],
      'end_date': payload['end_date'],
      'created_at': payload['created_at'],
    };
  }

  // ==========================================================
  // CLOUD → LOCAL
  // ==========================================================

  Future<void> _syncCloudToLocal(
    String userId,
  ) async {
    await _syncTransactionsFromCloud(userId);

    await _syncWalletsFromCloud(userId);

    await _syncCategoriesFromCloud(userId);

    await _syncBudgetsFromCloud(userId);
  }

  // ==========================================================
  // TRANSACTIONS CLOUD → LOCAL
  // ==========================================================

  Future<void> _syncTransactionsFromCloud(
    String userId,
  ) async {
    final transactions =
        await transactionRemote.getTransactions(
      userId,
    );

    for (final transaction in transactions) {
      final id =
          transaction['id']?.toString();

      if (id == null || id.isEmpty) {
        continue;
      }

      final pending =
          await syncQueue.getByEntityAndRecord(
        userId: userId,
        entityTable: 'transactions',
        recordId: id,
      );

      if (pending != null) {
        continue;
      }

      final existing =
          await transactionLocal
              .getTransactionById(id);

      if (existing != null &&
          existing.isDeleted) {
        continue;
      }

      final transactionDate =
          _parseDate(
        transaction['transaction_date'],
      );

      final createdAt =
          _parseDate(
        transaction['created_at'],
      );

      final companion =
          LocalTransactionsCompanion(
        id: drift.Value(id),
        userId: drift.Value(userId),
        walletId: _nullableValue(
          transaction['wallet_id'],
        ),
        categoryId: _nullableValue(
          transaction['category_id'],
        ),
        title: drift.Value(
          transaction['title']?.toString() ??
              '',
        ),
        amount: drift.Value(
          (transaction['amount'] as num?)
                  ?.toDouble() ??
              0.0,
        ),
        type: drift.Value(
          transaction['type']?.toString() ??
              'expense',
        ),
        transactionDate:
            drift.Value(transactionDate),
        note: _nullableValue(
          transaction['note'],
        ),
        createdAt:
            drift.Value(createdAt),
        updatedAt:
            drift.Value(DateTime.now()),
        version:
            const drift.Value(1),
        isDeleted:
            const drift.Value(false),
      );

      if (existing == null) {
        await transactionLocal
            .insertTransaction(
          companion,
        );
      } else {
        await transactionLocal
            .updateTransaction(
          id,
          companion,
        );
      }
    }
  }

  // ==========================================================
  // WALLETS CLOUD → LOCAL
  // ==========================================================

  Future<void> _syncWalletsFromCloud(
    String userId,
  ) async {
    final wallets =
        await walletRemote.getWallets(
      userId,
    );

    for (final wallet in wallets) {
      final id =
          wallet['id']?.toString();

      if (id == null || id.isEmpty) {
        continue;
      }

      final pending =
          await syncQueue.getByEntityAndRecord(
        userId: userId,
        entityTable: 'wallets',
        recordId: id,
      );

      if (pending != null) {
        continue;
      }

      final existing =
          await walletLocal.getWalletById(
        id,
      );

      if (existing != null &&
          existing.isDeleted) {
        continue;
      }

      final createdAt =
          _parseDate(
        wallet['created_at'],
      );

      final companion =
          LocalWalletsCompanion(
        id: drift.Value(id),
        userId: drift.Value(userId),
        name: drift.Value(
          wallet['name']?.toString() ??
              '',
        ),
        balance: drift.Value(
          (wallet['balance'] as num?)
                  ?.toDouble() ??
              0.0,
        ),
        currency: drift.Value(
          wallet['currency']?.toString() ??
              'PKR',
        ),
        type: drift.Value(
          wallet['type']?.toString() ??
              'Cash',
        ),
        createdAt:
            drift.Value(createdAt),
        updatedAt:
            drift.Value(DateTime.now()),
        version:
            const drift.Value(1),
        isDeleted:
            const drift.Value(false),
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

  // ==========================================================
  // CATEGORIES CLOUD → LOCAL
  // ==========================================================

  Future<void> _syncCategoriesFromCloud(
    String userId,
  ) async {
    final categories =
        await categoryRemote.getCategories(
      userId,
    );

    for (final category in categories) {
      final id =
          category['id']?.toString();

      if (id == null || id.isEmpty) {
        continue;
      }

      final pending =
          await syncQueue.getByEntityAndRecord(
        userId: userId,
        entityTable: 'categories',
        recordId: id,
      );

      if (pending != null) {
        continue;
      }

      final existing =
          await categoryLocal.getCategoryById(
        id,
      );

      if (existing != null &&
          existing.isDeleted) {
        continue;
      }

      final createdAt =
          _parseDate(
        category['created_at'],
      );

      final companion =
          LocalCategoriesCompanion(
        id: drift.Value(id),
        userId: drift.Value(userId),
        name: drift.Value(
          category['name']?.toString() ??
              '',
        ),
        type: drift.Value(
          category['type']?.toString() ??
              'expense',
        ),
        icon: _nullableValue(
          category['icon'],
        ),
        color: _nullableValue(
          category['color'],
        ),
        createdAt:
            drift.Value(createdAt),
        updatedAt:
            drift.Value(DateTime.now()),
        version:
            const drift.Value(1),
        isDeleted:
            const drift.Value(false),
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

  // ==========================================================
  // BUDGETS CLOUD → LOCAL
  // ==========================================================

  Future<void> _syncBudgetsFromCloud(
    String userId,
  ) async {
    final budgets =
        await budgetRemote.getBudgets(
      userId,
    );

    for (final budget in budgets) {
      final id =
          budget['id']?.toString();

      if (id == null || id.isEmpty) {
        continue;
      }

      final pending =
          await syncQueue.getByEntityAndRecord(
        userId: userId,
        entityTable: 'budgets',
        recordId: id,
      );

      if (pending != null) {
        continue;
      }

      final existing =
          await budgetLocal.getBudgetById(
        id,
      );

      if (existing != null &&
          existing.isDeleted) {
        continue;
      }

      final startDate =
          _parseDate(
        budget['start_date'],
      );

      final endDate =
          _parseDate(
        budget['end_date'],
      );

      final createdAt =
          _parseDate(
        budget['created_at'],
      );

      // Supabase budgets does NOT have
      // updated_at/version.
      // These values are local-only.
      final companion =
          LocalBudgetsCompanion(
        id: drift.Value(id),
        userId: drift.Value(userId),
        categoryId: _nullableValue(
          budget['category_id'],
        ),
        name: drift.Value(
          budget['name']?.toString() ??
              '',
        ),
        amount: drift.Value(
          (budget['amount'] as num?)
                  ?.toDouble() ??
              0.0,
        ),
        spent: drift.Value(
          (budget['spent'] as num?)
                  ?.toDouble() ??
              0.0,
        ),
        startDate:
            drift.Value(startDate),
        endDate:
            drift.Value(endDate),
        createdAt:
            drift.Value(createdAt),
        updatedAt:
            drift.Value(DateTime.now()),
        version:
            const drift.Value(1),
        isDeleted:
            const drift.Value(false),
      );

      if (existing == null) {
        await budgetLocal.insertBudget(
          companion,
        );
      } else {
        await budgetLocal.updateBudget(
          id,
          companion,
        );
      }
    }
  }

  // ==========================================================
  // PAYLOAD
  // ==========================================================

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

  // ==========================================================
  // DATE
  // ==========================================================

  DateTime _parseDate(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }

    return DateTime.tryParse(
          value.toString(),
        ) ??
        DateTime.now();
  }

  // ==========================================================
  // NULLABLE STRING
  // ==========================================================

  drift.Value<String?> _nullableValue(
    dynamic value,
  ) {
    if (value == null) {
      return const drift.Value(null);
    }

    final stringValue =
        value.toString();

    if (stringValue.isEmpty) {
      return const drift.Value(null);
    }

    return drift.Value(stringValue);
  }
}