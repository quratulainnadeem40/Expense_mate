import 'package:get/get.dart';
import '../model/budget_model.dart';

class BudgetController extends GetxController {
  var budgetList = <BudgetModel>[].obs;

  double get totalAllocated => budgetList.fold(0, (sum, item) => sum + item.allocatedAmount);
  double get totalSpent => budgetList.fold(0, (sum, item) => sum + item.spentAmount);

  @override
  void onInit() {
    super.onInit();
    loadBudgets();
  }

  void loadBudgets() {
    budgetList.assignAll([
      BudgetModel(id: '1', categoryName: 'Groceries', allocatedAmount: 20000, spentAmount: 12000),
      BudgetModel(id: '2', categoryName: 'Shopping', allocatedAmount: 15000, spentAmount: 4000),
    ]);
  }

  void addNewBudget(String category, double amount) {
    budgetList.add(
      BudgetModel(
        id: DateTime.now().toString(),
        categoryName: category,
        allocatedAmount: amount,
      ),
    );
  }
}