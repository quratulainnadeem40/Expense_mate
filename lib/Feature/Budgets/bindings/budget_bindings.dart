import 'package:get/get.dart';
import '../controller/budget_controller.dart';

class BudgetBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<BudgetController>(BudgetController(), permanent: true);
  }
}