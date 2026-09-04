import 'package:get/get.dart';
import '../controller/expense_controller.dart';

class ExpenseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExpenseController>(() => ExpenseController());
  }
}