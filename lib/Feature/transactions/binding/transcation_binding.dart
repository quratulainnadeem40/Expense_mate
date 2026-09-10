import 'package:get/get.dart';
import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';

class TransactionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionsController>(() => TransactionsController(), fenix: true);
  }
}