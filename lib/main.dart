import 'package:expense_mate/Feature/pin/view/pin_lock_view.dart';
import 'package:expense_mate/Core/service/pin_service.dart';
import 'package:expense_mate/Core/Database/repository_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Routes & Services Imports
import 'package:expense_mate/Core/routes/page_routes.dart';
import 'package:expense_mate/Core/routes/app_routes.dart';
import 'package:expense_mate/Core/service/notification_service.dart';
import 'package:expense_mate/Core/service/storage_service.dart';
import 'package:expense_mate/Core/theme/custom_theme.dart';
import 'package:expense_mate/Core/localization/app_translations.dart';

import 'package:expense_mate/Core/Database/sync/sync_manager.dart';
// Controllers Imports
import 'package:expense_mate/Feature/settings/controller/settings_controller.dart';
import 'package:expense_mate/Feature/reports/controller/report_controller.dart';
import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';
import 'package:expense_mate/Feature/committee/controller/committe_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Local Database Initialization
  RepositoryProvider.instance.database;

  // 2. Existing Hive Storage Initialization
  await StorageService.init();

  // 3. Supabase Initialization
  await Supabase.initialize(
    url: 'https://epjzyrjxrhbfdyrbdsli.supabase.co',
    publishableKey: 'sb_publishable_2VnrpBbdOhiJpqw74rhufg_rp8GgJ_p',
  );
  Get.put(SyncManager(), permanent: true);

  // 4. Notification Service
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermission();
  Get.put(notificationService, permanent: true);

  // 5. Global State Controllers Injection
  final settingsController = Get.put(SettingsController(), permanent: true);

  Get.put(ReportController(), permanent: true);
  Get.put(TransactionsController(), permanent: true);
  Get.put(CommitteeController.instance, permanent: true);

  runApp(ExpenseMateApp(settingsController: settingsController));
}

class ExpenseMateApp extends StatefulWidget {
  final SettingsController settingsController;

  const ExpenseMateApp({super.key, required this.settingsController});

  @override
  State<ExpenseMateApp> createState() => _ExpenseMateAppState();
}

class _ExpenseMateAppState extends State<ExpenseMateApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Locks the app again once it has been in the background long
  /// enough. The grace period means glancing at a notification does not
  /// force the PIN to be typed again.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final pin = PinService.instance;
    if (!pin.isPinSet) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      pin.onBackgrounded();
      return;
    }

    if (state == AppLifecycleState.resumed && pin.shouldLockOnResume()) {
      pin.lock();

      final current = Get.currentRoute;
      if (current == AppRoutes.pinLock || current == AppRoutes.splash) {
        return;
      }

      Get.offAllNamed(
        AppRoutes.pinLock,
        arguments: {PinLockView.argNextRoute: AppRoutes.home},
      );
    }
  }

  SettingsController get settingsController => widget.settingsController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        title: 'Expense Mate'.tr,
        debugShowCheckedModeBanner: false,
        translations: AppTranslations(),
        locale: Get.locale ?? Locale(settingsController.selectedLanguage.value),
        fallbackLocale: const Locale('en'),
        supportedLocales: AppTranslations.languageCodes
            .map((code) => Locale(code))
            .toList(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: AppTranslations.resolveFrameworkLocale,
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
