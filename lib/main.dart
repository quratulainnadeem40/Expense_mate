import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Routes & Services Imports
import 'package:expense_mate/Core/routes/page_routes.dart';
import 'package:expense_mate/Core/routes/app_routes.dart';
import 'package:expense_mate/Core/service/notification_service.dart';
import 'package:expense_mate/Core/service/storage_service.dart';
import 'package:expense_mate/Core/theme/custom_theme.dart';

// Controllers Imports
import 'package:expense_mate/Feature/settings/controller/settings_controller.dart';
// FIX: Changed 'Reports' to lowercase 'reports'
import 'package:expense_mate/Feature/reports/controller/report_controller.dart'; 
import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Storage Initialization
  await StorageService.init();

  // 2. Supabase Initialization
  await Supabase.initialize(
    url: 'https://epjzyrjxrhbfdyrbdsli.supabase.co',
    publishableKey: 'sb_publishable_2VnrpBbdOhiJpqw74rhufg_rp8GgJ_p',
  );

  // 3. Notification Service
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermission();
  Get.put(notificationService, permanent: true);

  // 4. Global State Controllers Injection
  final settingsController = Get.put(SettingsController(), permanent: true);
  Get.put(ReportController(), permanent: true);
  Get.put(TransactionsController(), permanent: true); 

  runApp(ExpenseMateApp(settingsController: settingsController));
}

class ExpenseMateApp extends StatelessWidget {
  final SettingsController settingsController;

  const ExpenseMateApp({super.key, required this.settingsController});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        title: 'Expense Mate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: settingsController.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,
        initialRoute: AppRoutes.splash,
        getPages: AppPages.pages,
      ),
    );
  }
}