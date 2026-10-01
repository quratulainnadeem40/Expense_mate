
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
  final SupabaseClient _supabase =
      Supabase.instance.client;

  // ==========================================================
  // TRANSACTIONS
  // ==========================================================

  final transactions =
      <TransactionModel>[].obs;

  // ==========================================================
  // TOTALS
  // ==========================================================

  final totalBalance = 0.0.obs;
  final totalIncome = 0.0.obs;
  final totalExpense = 0.0.obs;

  // ==========================================================
  // LOADING
  // ==========================================================

  final isLoading = false.obs;

  // ==========================================================
  // REPOSITORY
  // ==========================================================

  final RepositoryProvider _repositories =
      RepositoryProvider.instance;

  // ==========================================================
  // CURRENT USER
  // ==========================================================

  User? get currentUser =>
      _supabase.auth.currentUser;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void onInit() {
    super.onInit();

    loadTransactions();
  }

  // ==========================================================
  // LOAD TRANSACTIONS
  // ==========================================================

  Future<void> loadTransactions() async {
    final user = currentUser;

    if (user == null) {
      transactions.clear();
      _calculateTotals();
      return;
    }

    try {
      isLoading.value = true;

      // ------------------------------------------------------
      // First load local data
      // ------------------------------------------------------

      await _loadFromLocal(user.id);

      // ------------------------------------------------------
      // Then sync with server
      // ------------------------------------------------------

      try {
        final syncManager =
            Get.find<SyncManager>();

        await syncManager.sync();

        // Reload local data after sync
        await _loadFromLocal(user.id);
      } catch (_) {
        // Local data remains available
      }
    } catch (_) {
      _showError(
        'Unable to load transactions.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================================
  // LOAD FROM LOCAL DATABASE
  // ==========================================================

  Future<void> _loadFromLocal(
    String userId,
  ) async {
    final localTransactions =
        await _repositories.transactions
            .getTransactions(userId);

    final loadedTransactions =
        localTransactions
            .map(_localToModel)
            .toList();

    transactions.assignAll(
      loadedTransactions,
    );

    _calculateTotals();
  }

  // ==========================================================
  // ADD TRANSACTION
  // ==========================================================

  Future<bool> addTransaction(
    TransactionModel transaction,
  ) async {
    final user = currentUser;

    if (user == null) {
      _showError(
        'Please login first.',
      );
      return false;
    }

    try {
      isLoading.value = true;

      // ------------------------------------------------------
      // Generate transaction ID
      // ------------------------------------------------------

      final transactionId =
          _generateUuid();

      // ------------------------------------------------------
      // Create transaction with generated ID
      //
      // IMPORTANT:
      // customCategory is preserved for Reports.
      // ------------------------------------------------------

      final transactionWithId =
          TransactionModel(
        id: transactionId,
        userId: user.id,
        walletId: transaction.walletId,
        categoryId: transaction.categoryId,
        customCategory:
            transaction.customCategory,
        title: transaction.title,
        amount: transaction.amount,
        type: transaction.type
            .trim()
            .toLowerCase(),
        transactionDate:
            transaction.transactionDate,
        note: transaction.note,
        createdAt:
            transaction.createdAt,
      );

      // ------------------------------------------------------
      // Save transaction
      // ------------------------------------------------------

      await _repositories
          .transactionSync
          .createTransaction(
        userId: user.id,
        id: transactionWithId.id,
        walletId:
            transactionWithId.walletId,
        categoryId:
            transactionWithId.categoryId,
        title:
            transactionWithId.title,
        amount:
            transactionWithId.amount,
        type:
            transactionWithId.type,
        transactionDate:
            transactionWithId.transactionDate,
        note:
            transactionWithId.note,
        createdAt:
            transactionWithId.createdAt,
      );

      // ------------------------------------------------------
      // Update reactive list immediately
      // ------------------------------------------------------

      transactions.insert(
        0,
        transactionWithId,
      );

      // ------------------------------------------------------
      // Recalculate totals
      // ------------------------------------------------------

      _calculateTotals();

      // ------------------------------------------------------
      // Sync in background
      // ------------------------------------------------------

      _syncInBackground();

      return true;
    } catch (_) {
      _showError(
        'Unable to add transaction.',
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================================
  // UPDATE TRANSACTION
  // ==========================================================

  Future<bool> updateTransaction(
    TransactionModel transaction,
  ) async {
    final user = currentUser;

    if (user == null) {
      _showError(
        'Please login first.',
      );
      return false;
    }

    try {
      isLoading.value = true;

      // ------------------------------------------------------
      // Keep transaction type normalized
      // ------------------------------------------------------

      final updatedTransaction =
          TransactionModel(
        id: transaction.id,
        userId: transaction.userId.isNotEmpty
            ? transaction.userId
            : user.id,
        walletId: transaction.walletId,
        categoryId:
            transaction.categoryId,
        customCategory:
            transaction.customCategory,
        title: transaction.title,
        amount: transaction.amount,
        type: transaction.type
            .trim()
            .toLowerCase(),
        transactionDate:
            transaction.transactionDate,
        note: transaction.note,
        createdAt:
            transaction.createdAt,
      );

      // ------------------------------------------------------
      // Update database
      // ------------------------------------------------------

      await _repositories
          .transactionSync
          .updateTransaction(
        userId: user.id,
        id: updatedTransaction.id,
        walletId:
            updatedTransaction.walletId,
        categoryId:
            updatedTransaction.categoryId,
        title:
            updatedTransaction.title,
        amount:
            updatedTransaction.amount,
        type:
            updatedTransaction.type,
        transactionDate:
            updatedTransaction.transactionDate,
        note:
            updatedTransaction.note,
        createdAt:
            updatedTransaction.createdAt,
      );

      // ------------------------------------------------------
      // Update reactive list
      // ------------------------------------------------------

      final index =
          transactions.indexWhere(
        (item) =>
            item.id ==
            updatedTransaction.id,
      );

      if (index != -1) {
        transactions[index] =
            updatedTransaction;
      } else {
        transactions.insert(
          0,
          updatedTransaction,
        );
      }

      // ------------------------------------------------------
      // Recalculate totals
      // ------------------------------------------------------

      _calculateTotals();

      // ------------------------------------------------------
      // Sync in background
      // ------------------------------------------------------

      _syncInBackground();

      return true;
    } catch (_) {
      _showError(
        'Unable to update transaction.',
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================================
  // DELETE TRANSACTION
  // ==========================================================

  Future<bool> deleteTransaction(
    String transactionId,
  ) async {
    final user = currentUser;

    if (user == null) {
      _showError(
        'Please login first.',
      );
      return false;
    }

    try {
      isLoading.value = true;

      // ------------------------------------------------------
      // Delete from database
      // ------------------------------------------------------

      await _repositories
          .transactionSync
          .deleteTransaction(
        userId: user.id,
        id: transactionId,
      );

      // ------------------------------------------------------
      // Remove from reactive list
      // ------------------------------------------------------

      transactions.removeWhere(
        (transaction) =>
            transaction.id ==
            transactionId,
      );

      // ------------------------------------------------------
      // Recalculate totals
      // ------------------------------------------------------

      _calculateTotals();

      // ------------------------------------------------------
      // Sync in background
      // ------------------------------------------------------

      _syncInBackground();

      return true;
    } catch (_) {
      _showError(
        'Unable to delete transaction.',
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================================
  // BACKGROUND SYNC
  // ==========================================================

  void _syncInBackground() {
    try {
      if (Get.isRegistered<
          SyncManager>()) {
        unawaited(
          Get.find<SyncManager>().sync(),
        );
      }
    } catch (_) {
      // Local operation already saved.
    }
  }

  // ==========================================================
  // LOCAL DATABASE MODEL -> TRANSACTION MODEL
  // ==========================================================

  TransactionModel _localToModel(
    LocalTransaction local,
  ) {
    return TransactionModel(
      id: local.id,
      userId: local.userId,
      walletId:
          local.walletId ?? '',
      categoryId:
          local.categoryId ?? '',
      title: local.title,
      amount: local.amount,
      type: local.type
          .trim()
          .toLowerCase(),
      transactionDate:
          local.transactionDate,
      note: local.note,
      createdAt: local.createdAt,
    );
  }

  // ==========================================================
  // CALCULATE TOTALS
  // ==========================================================

  void _calculateTotals() {
    double income = 0.0;
    double expense = 0.0;

    for (final transaction
        in transactions) {
      final String type =
          transaction.type
              .trim()
              .toLowerCase();

      if (type == 'income') {
        income += transaction.amount;
      } else if (type == 'expense') {
        expense += transaction.amount;
      }
    }

    totalIncome.value = income;
    totalExpense.value = expense;
    totalBalance.value =
        income - expense;
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  void _showError(
    String message,
  ) {
    // Intentionally no snackbar.
  }

  // ==========================================================
  // UUID GENERATOR
  // ==========================================================

  String _generateUuid() {
    final random = Random();

    String hex(int count) {
      final value =
          List<int>.generate(
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

    // --------------------------------------------------------
    // UUID Part 1
    // --------------------------------------------------------

    final part1 = hex(4);

    // --------------------------------------------------------
    // UUID Part 2
    // --------------------------------------------------------

    final part2 = hex(2);

    // --------------------------------------------------------
    // UUID Part 3 - Version 4
    // --------------------------------------------------------

    final part3Bytes =
        List<int>.generate(
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

    // --------------------------------------------------------
    // UUID Part 4 - Variant
    // --------------------------------------------------------

    final part4Bytes =
        List<int>.generate(
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

    // --------------------------------------------------------
    // UUID Part 5
    // --------------------------------------------------------

    final part5 = hex(6);

    return '$part1-$part2-$part3-$part4-$part5';
  }
}

