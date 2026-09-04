import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';
import 'package:get/get.dart';

class TransactionsController extends GetxController {
  var transactionList = <TransactionModel>[].obs;
  
  var totalIncome = 0.0.obs;
  var totalExpense = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  void fetchTransactions() {
    // Dummy initial data for testing UI
    transactionList.value = [
      TransactionModel(
        id: '1',
        title: 'Grocery Store',
        amount: 45.50,
        category: 'Food & Dining',
        date: DateTime.now(),
        isIncome: false,
      ),
      TransactionModel(
        id: '2',
        title: 'Monthly Salary',
        amount: 2500.00,
        category: 'Salary',
        date: DateTime.now(),
        isIncome: true,
      ),
    ];
    calculateTotals();
  }

  void addTransaction(TransactionModel transaction) {
    transactionList.add(transaction);
    calculateTotals();
  }

  void deleteTransaction(String id) {
    transactionList.removeWhere((item) => item.id == id);
    calculateTotals();
  }

  void calculateTotals() {
    double income = 0.0;
    double expense = 0.0;

    for (var item in transactionList) {
      if (item.isIncome) {
        income += item.amount;
      } else {
        expense += item.amount;
      }
    }

    totalIncome.value = income;
    totalExpense.value = expense;
  }
}