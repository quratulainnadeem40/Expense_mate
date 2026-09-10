import 'package:get/get.dart';
import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';
import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';

class ReportController extends GetxController {
  late final TransactionsController _txController;

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

    if (Get.isRegistered<TransactionsController>()) {
      _txController = Get.find<TransactionsController>();
      _txController.loadTransactions();
    } else {
      Get.lazyPut<TransactionsController>(
        () => TransactionsController(),
      );

      _txController = Get.find<TransactionsController>();
      _txController.loadTransactions();
    }
  }
}