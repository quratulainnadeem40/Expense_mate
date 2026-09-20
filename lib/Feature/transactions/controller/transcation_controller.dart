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

      final response = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', user.id)
          .order('transaction_date', ascending: false);

      final data = response as List;

      final loadedTransactions = data.map((item) {
        return TransactionModel(
          id: item['id'].toString(),
          userId: item['user_id'].toString(),
          walletId: item['wallet_id'].toString(),
          categoryId: item['category_id'].toString(),
          title: item['title']?.toString() ?? '',
          amount: (item['amount'] as num).toDouble(),
          type: item['type'].toString(),
          transactionDate: DateTime.parse(
            item['transaction_date'].toString(),
          ),
          note: item['note']?.toString(),
        );
      }).toList();

      transactions.assignAll(loadedTransactions);

      _calculateTotals();
    } on PostgrestException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Unable to load transactions.');
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // ADD TRANSACTION
  // ============================================================

  Future<bool> addTransaction(TransactionModel transaction) async {
    final user = currentUser;

    if (user == null) {
      _showError('Please login first.');
      return false;
    }

    try {
      isLoading.value = true;

      final response = await _supabase
          .from('transactions')
          .insert({
            'user_id': user.id,
            'wallet_id': transaction.walletId,
            'category_id': transaction.categoryId,
            'title': transaction.title,
            'amount': transaction.amount,
            'type': transaction.type,
            'transaction_date':
                transaction.transactionDate.toIso8601String(),
            'note': transaction.note,
          })
          .select()
          .single();

      final addedTransaction = TransactionModel(
        id: response['id'].toString(),
        userId: response['user_id'].toString(),
        walletId: response['wallet_id'].toString(),
        categoryId: response['category_id'].toString(),
        title: response['title']?.toString() ?? '',
        amount: (response['amount'] as num).toDouble(),
        type: response['type'].toString(),
        transactionDate:
            DateTime.parse(response['transaction_date'].toString()),
        note: response['note']?.toString(),
      );

      transactions.insert(0, addedTransaction);

      _calculateTotals();

      return true;
    } on PostgrestException catch (e) {
      _showError(e.message);
      return false;
    } catch (e) {
      _showError('Unable to add transaction.');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // UPDATE TRANSACTION
  // ============================================================

  Future<bool> updateTransaction(TransactionModel transaction) async {
    final user = currentUser;

    if (user == null) {
      _showError('Please login first.');
      return false;
    }

    try {
      isLoading.value = true;

      final response = await _supabase
          .from('transactions')
          .update({
            'wallet_id': transaction.walletId,
            'category_id': transaction.categoryId,
            'title': transaction.title,
            'amount': transaction.amount,
            'type': transaction.type,
            'transaction_date':
                transaction.transactionDate.toIso8601String(),
            'note': transaction.note,
          })
          .eq('id', transaction.id)
          .eq('user_id', user.id)
          .select()
          .single();

      final updatedTransaction = TransactionModel(
        id: response['id'].toString(),
        userId: response['user_id'].toString(),
        walletId: response['wallet_id'].toString(),
        categoryId: response['category_id'].toString(),
        title: response['title']?.toString() ?? '',
        amount: (response['amount'] as num).toDouble(),
        type: response['type'].toString(),
        transactionDate:
            DateTime.parse(response['transaction_date'].toString()),
        note: response['note']?.toString(),
      );

      final index = transactions.indexWhere(
        (item) => item.id == transaction.id,
      );

      if (index != -1) {
        transactions[index] = updatedTransaction;
      }

      _calculateTotals();

      return true;
    } on PostgrestException catch (e) {
      _showError(e.message);
      return false;
    } catch (e) {
      _showError('Unable to update transaction.');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // DELETE TRANSACTION
  // ============================================================

  Future<bool> deleteTransaction(String transactionId) async {
    final user = currentUser;

    if (user == null) {
      _showError('Please login first.');
      return false;
    }

    try {
      isLoading.value = true;

      await _supabase
          .from('transactions')
          .delete()
          .eq('id', transactionId)
          .eq('user_id', user.id);

      transactions.removeWhere(
        (transaction) => transaction.id == transactionId,
      );

      _calculateTotals();

      return true;
    } on PostgrestException catch (e) {
      _showError(e.message);
      return false;
    } catch (e) {
      _showError('Unable to delete transaction.');
      return false;
    } finally {
      isLoading.value = false;
    }
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

 void _showError(String message) {
  if (Get.context == null) {
    return;
  }

  try {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  } catch (_) {
    // The widget tree may already be disposed.
  }
}
}