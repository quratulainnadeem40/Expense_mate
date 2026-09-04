import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_keys.dart';

class StorageService {
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Open Hive boxes required for MVP local storage (Hive offline-first feature from image roadmap)
    await Hive.openBox(AppKeys.transactionsBox);
    await Hive.openBox(AppKeys.categoriesBox);
    await Hive.openBox(AppKeys.settingsBox);
  }
}