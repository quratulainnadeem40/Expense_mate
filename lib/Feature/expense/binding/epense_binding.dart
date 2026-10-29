import 'package:expense_mate/Feature/expense/controller/expense_controller.dart';
import 'package:get/get.dart';

class ExpenseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExpenseController>(() => ExpenseController());
  }
}