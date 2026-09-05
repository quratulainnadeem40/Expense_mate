
import 'package:expense_mate/Feature/Budgets/bindings/budget_bindings.dart';
import 'package:expense_mate/Feature/Budgets/view/budget_view.dart';

import 'package:expense_mate/Feature/Categories/binding/categories_binding.dart';
import 'package:expense_mate/Feature/Categories/views/cataogries_view.dart';

import 'package:expense_mate/Feature/Home/binding/home_binding.dart';
import 'package:expense_mate/Feature/Home/view/home_screen.dart';
import 'package:expense_mate/Feature/bills_reminders/binding/bills_reminders_binding.dart';
import 'package:expense_mate/Feature/bills_reminders/view/bills_reminders_view.dart';
import 'package:expense_mate/Feature/settings/binding/settings_binding.dart';
import 'package:expense_mate/Feature/settings/view/settings_view.dart';

import 'package:expense_mate/Feature/splash/binding/splash_binding.dart';
import 'package:expense_mate/Feature/splash/view/splash_view_screen.dart';

import 'package:expense_mate/Feature/transactions/binding/transcation_binding.dart';
import 'package:expense_mate/Feature/transactions/view/transcatio_screen.dart';

import 'package:expense_mate/Feature/wallets/binding/wallets_binding.dart';
import 'package:expense_mate/Feature/wallets/view/wallets_view.dart';

import 'package:get/get.dart';

import 'app_routes.dart';

class AppPages {
  static final pages = [
    // ==========================================================
    // SPLASH
    // ==========================================================

    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),

    // ==========================================================
    // MAIN SECTIONS
    // ==========================================================

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

    // ==========================================================
    // BUDGET
    // ==========================================================

    GetPage(
      name: AppRoutes.budget,
      page: () => const BudgetView(),
      binding: BudgetBinding(),
    ),

    // ==========================================================
    // MEMBER 3 - WALLETS
    // ==========================================================

    GetPage(
      name: AppRoutes.wallets,
      page: () => const WalletsView(),
      binding: WalletsBinding(),
    ),
    GetPage(
      name: AppRoutes.billsReminders,
      page: () => const BillsRemindersView(),
      binding: BillsRemindersBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
  ];
}