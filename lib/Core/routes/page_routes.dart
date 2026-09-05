
import 'package:expense_mate/Feature/Budgets/bindings/budget_bindings.dart';
import 'package:expense_mate/Feature/Budgets/view/budget_view.dart';
import 'package:expense_mate/Feature/Categories/binding/categories_binding.dart';
import 'package:expense_mate/Feature/Categories/views/cataogries_view.dart';
import 'package:expense_mate/Feature/Home/binding/home_binding.dart';
import '' 'package:expense_mate/Feature/Home/view/home_screen.dart';
import 'package:expense_mate/Feature/transactions/binding/transcation_binding.dart';
import 'package:expense_mate/Feature/transactions/view/transcatio_screen.dart';
import 'package:get/get.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.transactions,
      page: () => const TransactionsView(),
      binding: TransactionsBinding(),
    ),
    GetPage(
      name: AppRoutes.categories,
      page: () => const CategoriesView(),
      binding: CategoriesBinding(),
    ),
    GetPage(
      name: AppRoutes.budget,
      page: () => const BudgetView(),
      binding: BudgetBinding(),
    ),
  ];
}