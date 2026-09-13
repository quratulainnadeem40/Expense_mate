import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionsController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final transactions = <TransactionModel>[].obs;
  final isLoading = false.obs;

  // Search related states
  final isSearching = false.obs;
  final searchQuery = ''.obs;

  User? get currentUser => _supabase.auth.currentUser;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  // ============================================================
  // SEARCH & TOGGLE
  // ============================================================

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchQuery.value = '';
    }
  }

  // Filter transactions based on title or note
  List<TransactionModel> get filteredTransactions {
    if (searchQuery.value.isEmpty) {
      return transactions;
    }
    final query = searchQuery.value.toLowerCase();
    return transactions.where((tx) {
      final titleMatch = tx.title.toLowerCase().contains(query);
      final noteMatch = tx.note?.toLowerCase().contains(query) ?? false;
      return titleMatch || noteMatch;
    }).toList();
  }

  // ============================================================
  // LOAD TRANSACTIONS
  // ============================================================

  Future<void> loadTransactions() async {
    final user = currentUser;

    if (user == null) {
      transactions.clear();
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

      final loadedTransactions = data
          .map(
            (item) => TransactionModel.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      transactions.assignAll(loadedTransactions);
    } on PostgrestException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Unable to load transactions.');
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // ADD TRANSACTION (FIXED FOR UUID & TYPE)
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

      // Dynamic Map to prevent UUID syntax errors for empty fields
      final Map<String, dynamic> insertData = {
        'user_id': user.id,
        'title': transaction.title,
        'amount': transaction.amount,
        'type': transaction.isIncome ? 'income' : 'expense',
        'transaction_date':
            (transaction.transactionDate ?? DateTime.now()).toIso8601String(),
        'note': transaction.note,
      };

      // Only add foreign keys if valid UUID strings exist
      if (transaction.walletId.isNotEmpty) {
        insertData['wallet_id'] = transaction.walletId;
      }

      if (transaction.categoryId.isNotEmpty) {
        insertData['category_id'] = transaction.categoryId;
      }

      await _supabase.from('transactions').insert(insertData);

      await loadTransactions();

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

  Future<bool> updateTransaction(
    TransactionModel transaction,
  ) async {
    final user = currentUser;

    if (user == null) {
      _showError('Please login first.');
      return false;
    }

    if (transaction.id.isEmpty) {
      _showError('Transaction ID is missing.');
      return false;
    }

    try {
      isLoading.value = true;

      final Map<String, dynamic> updateData = {
        'title': transaction.title,
        'amount': transaction.amount,
        'type': transaction.isIncome ? 'income' : 'expense',
        'transaction_date': transaction.transactionDate.toIso8601String(),
        'note': transaction.note,
      };

      if (transaction.walletId.isNotEmpty) {
        updateData['wallet_id'] = transaction.walletId;
      }

      if (transaction.categoryId.isNotEmpty) {
        updateData['category_id'] = transaction.categoryId;
      }

      await _supabase
          .from('transactions')
          .update(updateData)
          .eq('id', transaction.id)
          .eq('user_id', user.id);

      await loadTransactions();

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

  Future<bool> deleteTransaction(String id) async {
    final user = currentUser;

    if (user == null) {
      _showError('Please login first.');
      return false;
    }

    if (id.isEmpty) {
      _showError('Transaction ID is missing.');
      return false;
    }

    try {
      isLoading.value = true;

      await _supabase
          .from('transactions')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id);

      await loadTransactions();

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
  // HELPERS
  // ============================================================

  double get totalIncome {
    return transactions
        .where((transaction) => transaction.isIncome)
        .fold(
          0.0,
          (sum, transaction) => sum + transaction.amount,
        );
  }

  double get totalExpense {
    return transactions
        .where((transaction) => transaction.isExpense)
        .fold(
          0.0,
          (sum, transaction) => sum + transaction.amount,
        );
  }

  double get balance {
    return totalIncome - totalExpense;
  }

  void _searchError(String message) {
    _showError(message);
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}