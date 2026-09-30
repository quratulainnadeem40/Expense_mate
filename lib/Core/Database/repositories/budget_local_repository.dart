import 'package:drift/drift.dart';

import '../app_database.dart';

class BudgetLocalRepository {
  final AppDatabase database;

  BudgetLocalRepository(this.database);

  // Get all active budgets for a user
  Future<List<LocalBudget>> getBudgets(String userId) {
    return (database.select(database.localBudgets)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.isDeleted.equals(false),
          )
          ..orderBy([
            (tbl) =>
                OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  // Get a single budget by ID
  Future<LocalBudget?> getBudgetById(String id) {
    return (database.select(database.localBudgets)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  // Get budget by category
  Future<LocalBudget?> getBudgetByCategory({
    required String userId,
    required String categoryId,
  }) {
    return (database.select(database.localBudgets)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.categoryId.equals(categoryId) &
                tbl.isDeleted.equals(false),
          ))
        .getSingleOrNull();
  }

  // Insert budget
  Future<void> insertBudget(LocalBudgetsCompanion budget) async {
    await database.into(database.localBudgets).insert(budget);
  }

  // Update budget
  Future<void> updateBudget(
    String id,
    LocalBudgetsCompanion budget,
  ) async {
    await (database.update(database.localBudgets)
          ..where((tbl) => tbl.id.equals(id)))
        .write(budget);
  }

  // Soft delete budget
  Future<void> softDeleteBudget(String id) async {
    await (database.update(database.localBudgets)
          ..where((tbl) => tbl.id.equals(id)))
        .write(
      LocalBudgetsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Restore a deleted budget
  Future<void> restoreBudget(String id) async {
    await (database.update(database.localBudgets)
          ..where((tbl) => tbl.id.equals(id)))
        .write(
      LocalBudgetsCompanion(
        isDeleted: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Get deleted budgets
  Future<List<LocalBudget>> getDeletedBudgets(String userId) {
    return (database.select(database.localBudgets)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.isDeleted.equals(true),
          ))
        .get();
  }

  // Permanently delete budget
  Future<void> permanentDeleteBudget(String id) async {
    await (database.delete(database.localBudgets)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  // Delete all budgets for a user
  Future<void> deleteAllBudgets(String userId) async {
    await (database.delete(database.localBudgets)
          ..where((tbl) => tbl.userId.equals(userId)))
        .go();
  }
}