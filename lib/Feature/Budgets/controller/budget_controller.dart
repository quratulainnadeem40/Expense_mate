import 'package:get/get.dart';
import '../../Categories/controller/categories_controller.dart';
import '../../Categories/model/categories_model.dart';
import '../../transactions/controller/transcation_controller.dart';
import '../model/budget_model.dart';

class BudgetController extends GetxController {
  late CategoriesController categoriesController;
  late TransactionsController transactionsController;

  var customLimits = <String, double>{}.obs; 
  var budgetList = <BudgetModel>[].obs;
  
  var customTotalBudget = Rxn<double>();

  @override
  void onInit() {
    super.onInit();

    categoriesController = Get.isRegistered<CategoriesController>()
        ? Get.find<CategoriesController>()
        : Get.put(CategoriesController());

    transactionsController = Get.isRegistered<TransactionsController>()
        ? Get.find<TransactionsController>()
        : Get.put(TransactionsController());

    ever(transactionsController.transactions, (_) => calculateBudgets());
    ever(categoriesController.categoryList, (_) => calculateBudgets());
    ever(customLimits, (_) => calculateBudgets());
    ever(customTotalBudget, (_) => calculateBudgets());

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

    budgetList.assignAll(tempList);
  }

  double get totalAllocated => customTotalBudget.value ?? 
      budgetList.fold(0.0, (sum, item) => sum + item.allocatedAmount);

  double get totalSpent => budgetList.fold(0.0, (sum, item) => sum + item.spentAmount);

  void setCategoryLimit(String categoryName, double newLimit) {
    customLimits[categoryName] = newLimit;
    calculateBudgets();
  }

  void setTotalBudget(double newTotalLimit) {
    customTotalBudget.value = newTotalLimit;
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