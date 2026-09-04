import 'package:expense_mate/Core/routes/page_routes.dart';
import 'package:expense_mate/Core/theme/custom_thene.dart';
import 'package:expense_mate/Feature/Home/view/main_screen.dart';
import 'package:expense_mate/core/routes/app_routes.dart';
import 'package:expense_mate/core/service/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hive storage initialization (Yeh hatana nahi hai warna data load nahi hoga)
  await StorageService.init();

  runApp(const ExpenseMateApp());
}

class ExpenseMateApp extends StatelessWidget {
  const ExpenseMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Expense Mate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainScreen(), // Yahan HomeScreen ki jagah MainScreen set kar diya hai
      getPages: AppPages.pages,
    );
  }
}