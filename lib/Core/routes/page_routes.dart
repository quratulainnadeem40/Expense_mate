
import 'package:expense_mate/Feature/Budgets/bindings/budget_bindings.dart';
import 'package:expense_mate/Feature/Budgets/view/budget_view.dart';

import 'package:expense_mate/Feature/Categories/binding/categories_binding.dart';
import 'package:expense_mate/Feature/Categories/views/cataogries_view.dart';

import 'package:expense_mate/Feature/goals/binding/goals_binding.dart';
import 'package:expense_mate/Feature/goals/view/goals_view.dart';

import 'package:expense_mate/Feature/home/binding/home_binding.dart';
import 'package:expense_mate/Feature/home/view/main_screen.dart';

import 'package:expense_mate/Feature/reports/bindings/report_bindings.dart';
import 'package:expense_mate/Feature/reports/view/report_view.dart';

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

import 'package:expense_mate/Feature/auth/binding/auth_binding.dart';
import 'package:expense_mate/Feature/auth/view/login_view.dart';
import 'package:expense_mate/Feature/auth/view/signup_view.dart';
import 'package:expense_mate/Feature/auth/view/forgot_password_view.dart';

import 'package:get/get.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    

    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),

    
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupView(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),


    GetPage(
      name: AppRoutes.transactions,
      page: () => TransactionsView(),
      binding: TransactionsBinding(),
    ),


    GetPage(
      name: AppRoutes.categories,
      page: () => CategoriesView(),
      binding: CategoriesBinding(),
    ),


    GetPage(
      name: AppRoutes.home,
      page: () => const MainScreen(),
      binding: HomeBinding(),
    ),


    GetPage(
      name: AppRoutes.budget,
      page: () => const BudgetView(),
      binding: BudgetBinding(),
    ),


    GetPage(
      name: AppRoutes.goals,
      page: () => const GoalsView(),
      binding: GoalsBinding(),
    ),


    GetPage(
      name: AppRoutes.reports,
      page: () => ReportView(),
      binding: ReportBindings(),
    ),


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
    ),
  ];
}

