import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_keys.dart';

class TransactionsController extends GetxController {
  var transactions = <TransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    if (!Hive.isBoxOpen(AppKeys.transactionsBox)) {
      await Hive.openBox(AppKeys.transactionsBox);
    }

    final box = Hive.box(AppKeys.transactionsBox);
    final List<TransactionModel> loadedList = [];

    for (var value in box.values) {
      if (value is Map) {
        final mapData = Map<String, dynamic>.from(value);
        
        // Income vs Expense handling fix
        final String typeStr = (mapData['type'] ?? 'Expense').toString().toLowerCase();
        final bool isInc = (typeStr == 'income');

        loadedList.add(
          TransactionModel(
            id: mapData['id'] ?? '',
            title: mapData['note'] ?? '',
            amount: (mapData['amount'] as num?)?.toDouble() ?? 0.0,
            category: mapData['category'] ?? '',
            date: DateTime.tryParse(mapData['date'] ?? '') ?? DateTime.now(),
            isIncome: isInc,
          ),
        );
      }
    }

    transactions.assignAll(loadedList.reversed);
  }

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
    await loadTransactions();
  }

  void deleteTransaction(String id) async {
    if (!Hive.isBoxOpen(AppKeys.transactionsBox)) return;
    final box = Hive.box(AppKeys.transactionsBox);

    final Map<dynamic, dynamic> rawMap = box.toMap();
    for (var entry in rawMap.entries) {
      if (entry.value is Map && entry.value['id'] == id) {
        await box.delete(entry.key);
      }
    }
    await loadTransactions();
  }
}