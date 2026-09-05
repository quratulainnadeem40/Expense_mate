import 'package:get/get.dart';
import '../../Categories/controller/categories_controller.dart';
import '../../Categories/model/categories_model.dart';
import '../../transactions/controller/transcation_controller.dart';
import '../model/budget_model.dart';

class BudgetController extends GetxController {
  final CategoriesController categoriesController = Get.find<CategoriesController>();
  final TransactionsController transactionsController = Get.find<TransactionsController>();

  var customLimits = <String, double>{}.obs; 
  var budgetList = <BudgetModel>[].obs; // Reactive List

  @override
  void onInit() {
    super.onInit();
    // Jab bhi transactions ya categories update hon, budget list auto-recalculate ho
    ever(transactionsController.transactions, (_) => calculateBudgets());
    ever(categoriesController.categoryList, (_) => calculateBudgets());
    ever(customLimits, (_) => calculateBudgets());
    
    calculateBudgets();
  }

  void calculateBudgets() {
    final categories = categoriesController.categoryList;
    final transactionsList = transactionsController.transactions;

    final List<BudgetModel> tempList = categories.map((cat) {
      double spent = transactionsList
          .where((t) => 
              t.category.trim().toLowerCase() == cat.name.trim().toLowerCase() && 
              !t.isIncome)
          .fold(0.0, (sum, t) => sum + t.amount);

      double limit = customLimits[cat.name] ?? 10000.0; 

      return BudgetModel(
        id: cat.id,
        categoryName: cat.name,
        allocatedAmount: limit,
        spentAmount: spent,
      );
    }).toList();

    budgetList.assignAll(tempList); // Reactive List update
  }

  double get totalAllocated => budgetList.fold(0, (sum, item) => sum + item.allocatedAmount);
  double get totalSpent => budgetList.fold(0, (sum, item) => sum + item.spentAmount);

  void setCategoryLimit(String categoryName, double newLimit) {
    customLimits[categoryName] = newLimit;
    calculateBudgets();
  }

  void addNewBudget(String categoryName, double amount) {
    customLimits[categoryName] = amount;

    bool exists = categoriesController.categoryList.any(
      (element) => element.name.trim().toLowerCase() == categoryName.trim().toLowerCase(),
    );

    if (!exists) {
      categoriesController.addCategory(
        CategoryModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: categoryName,
          icon: 'attach_money',
          colorValue: 0xFF2B82FB,
          isDefault: false,
        ),
      );
    }

    calculateBudgets();
  }
}