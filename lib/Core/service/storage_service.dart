import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_keys.dart';

class StorageService {
  static Future<void> init() async {
    await Hive.initFlutter();

    await Hive.openBox(AppKeys.transactionsBox);
    await Hive.openBox(AppKeys.categoriesBox);

    await Hive.openBox(AppKeys.walletsBox);
    await Hive.openBox(AppKeys.billsRemindersBox);

    await Hive.openBox(AppKeys.settingsBox);
  }
}