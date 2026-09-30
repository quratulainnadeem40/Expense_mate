import 'dart:async';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:expense_mate/Core/Database/app_database.dart';
import 'package:expense_mate/Core/Database/repository_provider.dart';
import 'package:expense_mate/Core/Database/sync/sync_manager.dart';
import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionsController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final transactions = <TransactionModel>[].obs;

  final totalBalance = 0.0.obs;
  final totalIncome = 0.0.obs;
  final totalExpense = 0.0.obs;

  final isLoading = false.obs;

  final RepositoryProvider _repositories =
      RepositoryProvider.instance;

  User? get currentUser => _supabase.auth.currentUser;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  // ============================================================
  // LOAD TRANSACTIONS
  // ============================================================

  Future<void> loadTransactions() async {
    final user = currentUser;

    if (user == null) {
      transactions.clear();
      _calculateTotals();
      return;
    }

    try {
      isLoading.value = true;

      // --------------------------------------------------------
      // STEP 1: Load local SQLite data first.
      // --------------------------------------------------------

      await _loadFromLocal(user.id);

      // --------------------------------------------------------
      // STEP 2: Try to synchronize with Supabase.
      //
      // If internet is unavailable, local data remains usable.
      // --------------------------------------------------------

      try {
        final syncManager = Get.find<SyncManager>();

        await syncManager.sync();

        // ------------------------------------------------------
        // STEP 3: Reload local data after synchronization.
        // ------------------------------------------------------

        await _loadFromLocal(user.id);
      } catch (_) {
        // Offline or temporary cloud failure.
        //
        // We intentionally keep the local data already loaded.
      }
    } catch (_) {
      _showError('Unable to load transactions.');
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // LOAD FROM LOCAL DATABASE
  // ============================================================

  Future<void> _loadFromLocal(
    String userId,
  ) async {
    final localTransactions =
        await _repositories.transactions.getTransactions(
      userId,
    );

    final loadedTransactions = localTransactions
        .map(_localToModel)
        .toList();

    transactions.assignAll(loadedTransactions);

    _calculateTotals();
  }

  // ============================================================
  // ADD TRANSACTION
  // ============================================================

  Future<bool> addTransaction(
    TransactionModel transaction,
  ) async {
    final user = currentUser;

    if (user == null) {
      _showError('Please login first.');
      return false;
    }

    try {
      isLoading.value = true;

      // --------------------------------------------------------
      // Generate a UUID locally.
      //
      // This allows the transaction to be created while offline.
      // --------------------------------------------------------

      final transactionId = _generateUuid();

      final transactionWithId = TransactionModel(
        id: transactionId,
        userId: user.id,
        walletId: transaction.walletId,
        categoryId: transaction.categoryId,
        title: transaction.title,
        amount: transaction.amount,
        type: transaction.type,
        transactionDate: transaction.transactionDate,
        note: transaction.note,
        createdAt: transaction.createdAt,
      );

      // --------------------------------------------------------
      // LOCAL FIRST
      // --------------------------------------------------------

      await _repositories.transactionSync.createTransaction(
        userId: user.id,
        id: transactionWithId.id,
        walletId: transactionWithId.walletId,
        categoryId: transactionWithId.categoryId,
        title: transactionWithId.title,
        amount: transactionWithId.amount,
        type: transactionWithId.type,
        transactionDate: transactionWithId.transactionDate,
        note: transactionWithId.note,
        createdAt: transactionWithId.createdAt,
      );

      // --------------------------------------------------------
      // Update UI immediately.
      // --------------------------------------------------------

      transactions.insert(
        0,
        transactionWithId,
      );

      _calculateTotals();

      // --------------------------------------------------------
      // Try cloud synchronization.
      //
      // Local operation is already safe in SQLite, so a cloud
      // failure does not make the add operation fail.
      // --------------------------------------------------------

      _syncInBackground();

      return true;
    } catch (_) {
      _showError('Unable to add transaction.');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // UPDATE TRANSACTION
  // ============================================================

  Future<bool> updateTransaction(
    TransactionModel transaction,
  ) async {
    final user = currentUser;

    if (user == null) {
      _showError('Please login first.');
      return false;
    }

    try {
      isLoading.value = true;

      // --------------------------------------------------------
      // LOCAL FIRST
      // --------------------------------------------------------

      await _repositories.transactionSync.updateTransaction(
        userId: user.id,
        id: transaction.id,
        walletId: transaction.walletId,
        categoryId: transaction.categoryId,
        title: transaction.title,
        amount: transaction.amount,
        type: transaction.type,
        transactionDate: transaction.transactionDate,
        note: transaction.note,
        createdAt: transaction.createdAt,
      );

      // --------------------------------------------------------
      // Update observable list immediately.
      // --------------------------------------------------------

      final index = transactions.indexWhere(
        (item) => item.id == transaction.id,
      );

      if (index != -1) {
        transactions[index] = transaction;
      } else {
        transactions.insert(
          0,
          transaction,
        );
      }

      _calculateTotals();

      // --------------------------------------------------------
      // Background synchronization.
      // --------------------------------------------------------

      _syncInBackground();

      return true;
    } catch (_) {
      _showError('Unable to update transaction.');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // DELETE TRANSACTION
  // ============================================================

  Future<bool> deleteTransaction(
    String transactionId,
  ) async {
    final user = currentUser;

    if (user == null) {
      _showError('Please login first.');
      return false;
    }

    try {
      isLoading.value = true;

      // --------------------------------------------------------
      // LOCAL FIRST
      // --------------------------------------------------------

      await _repositories.transactionSync.deleteTransaction(
        userId: user.id,
        id: transactionId,
      );

      // --------------------------------------------------------
      // Remove from UI immediately.
      // --------------------------------------------------------

      transactions.removeWhere(
        (transaction) => transaction.id == transactionId,
      );

      _calculateTotals();

      // --------------------------------------------------------
      // Background synchronization.
      // --------------------------------------------------------

      _syncInBackground();

      return true;
    } catch (_) {
      _showError('Unable to delete transaction.');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // BACKGROUND SYNC
  // ============================================================

  void _syncInBackground() {
    try {
      if (Get.isRegistered<SyncManager>()) {
        unawaited(
          Get.find<SyncManager>().sync(),
        );
      }
    } catch (_) {
      // The local operation has already been saved.
      //
      // SyncManager will retry the queued operation later.
    }
  }

  // ============================================================
  // LOCAL DATABASE → MODEL
  // ============================================================

  TransactionModel _localToModel(
    LocalTransaction local,
  ) {
    return TransactionModel(
      id: local.id,
      userId: local.userId,
      walletId: local.walletId ?? '',
      categoryId: local.categoryId ?? '',
      title: local.title,
      amount: local.amount,
      type: local.type,
      transactionDate: local.transactionDate,
      note: local.note,
      createdAt: local.createdAt,
    );
  }

  // ============================================================
  // TOTALS
  // ============================================================

  void _calculateTotals() {
    double income = 0.0;
    double expense = 0.0;

    for (final transaction in transactions) {
      if (transaction.isIncome) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    totalIncome.value = income;
    totalExpense.value = expense;
    totalBalance.value = income - expense;
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(
    String message,
  ) {
    // We intentionally do not use Get.snackbar here.
    //
    // GetX snackbar previously caused:
    // LateInitializationError: Field '_animation'
    // has not been initialized.
    //
    // The controller remains UI-independent.
    //
    // The calling screen can display errors using its own
    // ScaffoldMessenger if required.
  }

  // ============================================================
  // LOCAL UUID GENERATOR
  // ============================================================

  String _generateUuid() {
    final random = Random();

    String hex(int count) {
      final value = List<int>.generate(
        count,
        (_) => random.nextInt(256),
      );

      return value
          .map(
            (number) => number
                .toRadixString(16)
                .padLeft(2, '0'),
          )
          .join();
    }

    final part1 = hex(4);
    final part2 = hex(2);

    final part3Bytes = List<int>.generate(
      2,
      (_) => random.nextInt(256),
    );

    part3Bytes[0] =
        (part3Bytes[0] & 0x0f) | 0x40;

    final part3 = part3Bytes
        .map(
          (number) => number
              .toRadixString(16)
              .padLeft(2, '0'),
        )
        .join();

    final part4Bytes = List<int>.generate(
      2,
      (_) => random.nextInt(256),
    );

    part4Bytes[0] =
        (part4Bytes[0] & 0x3f) | 0x80;

    final part4 = part4Bytes
        .map(
          (number) => number
              .toRadixString(16)
              .padLeft(2, '0'),
        )
        .join();

    final part5 = hex(6);

    return '$part1-$part2-$part3-$part4-$part5';
  }
}
