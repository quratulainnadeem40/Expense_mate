class BudgetModel {
  final String id;
  final String categoryName;
  final double allocatedAmount;
  final double spentAmount;

  BudgetModel({
    required this.id,
    required this.categoryName,
    required this.allocatedAmount,
    this.spentAmount = 0.0,
  });

  double get remainingAmount => allocatedAmount - spentAmount;
  double get progress => (allocatedAmount > 0) ? (spentAmount / allocatedAmount).clamp(0.0, 1.0) : 0.0;
}

// =====================================================================
// SAVED CYCLES
// Kept in this same file so no new file has to be created.
// =====================================================================

/// One finished budget cycle, saved the moment a reset happens.
///
/// The limit is stored alongside the spend, so a past cycle always shows
/// the numbers that were true back then, even if limits change later.
class BudgetCycleHistory {
  BudgetCycleHistory({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.totalLimit,
    required this.totalSpent,
    required this.categories,
    this.wasAutomatic = false,
  });

  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final double totalLimit;
  final double totalSpent;
  final List<CategoryCycleEntry> categories;

  /// True when the app reset it on its own.
  final bool wasAutomatic;

  /// Positive means money was left over, negative means overspent.
  double get difference => totalLimit - totalSpent;

  bool get isSaved => difference >= 0;

  double get progress =>
      totalLimit > 0 ? (totalSpent / totalLimit).clamp(0.0, 1.0) : 0.0;

  int get progressPercent =>
      totalLimit > 0 ? ((totalSpent / totalLimit) * 100).round() : 0;

  int get lengthInDays => endDate.difference(startDate).inDays + 1;

  Map<String, dynamic> toMap() => {
        'id': id,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'totalLimit': totalLimit,
        'totalSpent': totalSpent,
        'wasAutomatic': wasAutomatic,
        'categories': categories.map((c) => c.toMap()).toList(),
      };

  factory BudgetCycleHistory.fromMap(Map<String, dynamic> map) {
    final rawCategories = map['categories'];

    return BudgetCycleHistory(
      id: map['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      startDate: DateTime.tryParse(map['startDate']?.toString() ?? '') ??
          DateTime.now(),
      endDate: DateTime.tryParse(map['endDate']?.toString() ?? '') ??
          DateTime.now(),
      totalLimit: (map['totalLimit'] as num?)?.toDouble() ?? 0.0,
      totalSpent: (map['totalSpent'] as num?)?.toDouble() ?? 0.0,
      wasAutomatic: map['wasAutomatic'] == true,
      categories: rawCategories is List
          ? rawCategories
              .map((e) => CategoryCycleEntry.fromMap(
                    Map<String, dynamic>.from(e as Map),
                  ))
              .toList()
          : <CategoryCycleEntry>[],
    );
  }
}

/// One category's figures inside a finished cycle.
class CategoryCycleEntry {
  CategoryCycleEntry({
    required this.name,
    required this.limit,
    required this.spent,
  });

  final String name;
  final double limit;
  final double spent;

  double get difference => limit - spent;

  bool get isOver => spent > limit && limit > 0;

  double get progress => limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;

  Map<String, dynamic> toMap() => {
        'name': name,
        'limit': limit,
        'spent': spent,
      };

  factory CategoryCycleEntry.fromMap(Map<String, dynamic> map) =>
      CategoryCycleEntry(
        name: map['name']?.toString() ?? 'Unknown',
        limit: (map['limit'] as num?)?.toDouble() ?? 0.0,
        spent: (map['spent'] as num?)?.toDouble() ?? 0.0,
      );
}