import 'package:expense_mate/Core/routes/page_routes.dart';
import 'package:expense_mate/Core/service/notification_service.dart';
import 'package:expense_mate/Core/theme/custom_theme.dart';
import 'package:expense_mate/Feature/Home/view/main_screen.dart';
import 'package:expense_mate/Feature/settings/controller/settings_controller.dart';
import 'package:expense_mate/core/service/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageService.init();

  final settingsController = Get.put(
    SettingsController(),
    permanent: true,
  );

  final notificationService = NotificationService();

  await notificationService.init();
  await notificationService.requestPermission();

  Get.put(
    notificationService,
    permanent: true,
  );

  runApp(
    ExpenseMateApp(
      settingsController: settingsController,
    ),
  );
}

class ExpenseMateApp extends StatelessWidget {
  final SettingsController settingsController;

  const ExpenseMateApp({
    super.key,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Expense Mate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsController.isDarkMode.value
          ? ThemeMode.dark
          : ThemeMode.light,
      home: const MainScreen(),
      getPages: AppPages.pages,
    );
  }
}