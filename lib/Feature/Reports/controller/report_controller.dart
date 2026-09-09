import 'package:get/get.dart';
import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';
import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';

class ReportController extends GetxController {
  // Controller lookup fallback logic
  TransactionsController get _txController =>
      Get.isRegistered<TransactionsController>()
          ? Get.find<TransactionsController>()
          : Get.put(TransactionsController());

  // Safe getter for reactive transactions
  RxList<TransactionModel> get transactions => _txController.transactions;

  double get totalIncome => transactions
      .where((tx) => tx.isIncome)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalExpense => transactions
      .where((tx) => !tx.isIncome)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalBalance => totalIncome - totalExpense;

  @override
  void onInit() {
    super.onInit();
    _txController.loadTransactions();
  }
}