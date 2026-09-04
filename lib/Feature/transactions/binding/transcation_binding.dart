import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';
import 'package:get/get.dart';

class TransactionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionsController>(() => TransactionsController());
  }
}