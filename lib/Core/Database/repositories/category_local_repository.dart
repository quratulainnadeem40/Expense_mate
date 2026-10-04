import 'package:drift/drift.dart';

import '../app_database.dart';

class CategoryLocalRepository {
  final AppDatabase database;

  CategoryLocalRepository(this.database);

  Future<List<LocalCategory>> getCategories(
    String userId,
  ) {
    return (database.select(database.localCategories)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.isDeleted.equals(false),
          )
          ..orderBy([
            (tbl) => OrderingTerm(
                  expression: tbl.createdAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  Future<LocalCategory?> getCategoryById(
    String categoryId,
  ) {
    return (database.select(database.localCategories)
          ..where(
            (tbl) => tbl.id.equals(categoryId),
          ))
        .getSingleOrNull();
  }

  Future<void> insertCategory(
    LocalCategoriesCompanion category,
  ) async {
    await database
        .into(database.localCategories)
        .insert(category);
  }

  Future<bool> updateCategory(
    String categoryId,
    LocalCategoriesCompanion category,
  ) async {
    return database
        .update(database.localCategories)
        .replace(
          category.copyWith(
            id: Value(categoryId),
          ),
        );
  }

  Future<int> softDeleteCategory(
    String categoryId,
  ) async {
    return (database.update(database.localCategories)
          ..where(
            (tbl) => tbl.id.equals(categoryId),
          ))
        .write(
      LocalCategoriesCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> restoreCategory(
    String categoryId,
  ) async {
    return (database.update(database.localCategories)
          ..where(
            (tbl) => tbl.id.equals(categoryId),
          ))
        .write(
      LocalCategoriesCompanion(
        isDeleted: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<LocalCategory>> getDeletedCategories(
    String userId,
  ) {
    return (database.select(database.localCategories)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.isDeleted.equals(true),
          ))
        .get();
  }

  Future<int> permanentlyDeleteCategory(
  String categoryId,
) {
  return (database.delete(database.localCategories)
        ..where(
          (tbl) => tbl.id.equals(categoryId),
        ))
      .go();
}
}