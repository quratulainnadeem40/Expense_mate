import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_keys.dart';

class TransactionsController extends GetxController {
  
  // Naya data Hive mein insert karne ke liye
  void addTransaction(TransactionModel transaction) async {
    if (!Hive.isBoxOpen(AppKeys.transactionsBox)) {
      await Hive.openBox(AppKeys.transactionsBox);
    }

    final box = Hive.box(AppKeys.transactionsBox);

    Map<String, dynamic> mapData = {
      'id': transaction.id,
      'note': transaction.title,
      'amount': transaction.amount,
      'category': transaction.category,
      'date': transaction.date.toIso8601String(),
      'type': transaction.isIncome ? 'Income' : 'Expense',
    };

    await box.add(mapData);
  }

  // Delete transaction logic
  void deleteTransaction(String id) async {
    if (!Hive.isBoxOpen(AppKeys.transactionsBox)) return;
    final box = Hive.box(AppKeys.transactionsBox);
    
    final Map<dynamic, dynamic> rawMap = box.toMap();
    rawMap.forEach((key, value) async {
      if (value is Map && value['id'] == id) {
        await box.delete(key);
      }
    });
  }
}