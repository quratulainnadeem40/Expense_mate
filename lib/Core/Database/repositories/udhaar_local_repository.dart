import 'package:drift/drift.dart';

import '../app_database.dart';

class UdhaarLocalRepository {
  final AppDatabase database;

  UdhaarLocalRepository(this.database);

  // ------------------------------------------------------------
  // GET ALL ACTIVE ENTRIES
  // ------------------------------------------------------------

  Future<List<LocalUdhaarEntry>> getEntries(String userId) {
    return (database.select(database.localUdhaarEntries)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.isDeleted.equals(false),
          )
          ..orderBy([
            (tbl) => OrderingTerm(
                  expression: tbl.entryDate,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  // ------------------------------------------------------------
  // GET ENTRY BY ID
  // ------------------------------------------------------------

  Future<LocalUdhaarEntry?> getEntryById(String id) {
    return (database.select(database.localUdhaarEntries)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  // ------------------------------------------------------------
  // INSERT ENTRY
  // ------------------------------------------------------------

  Future<void> insertEntry(
    LocalUdhaarEntriesCompanion entry,
  ) async {
    await database.into(database.localUdhaarEntries).insert(entry);
  }

  // ------------------------------------------------------------
  // UPDATE ENTRY
  // ------------------------------------------------------------

  Future<void> updateEntry(
    String id,
    LocalUdhaarEntriesCompanion entry,
  ) async {
    await (database.update(database.localUdhaarEntries)
          ..where((tbl) => tbl.id.equals(id)))
        .write(entry);
  }

  // ------------------------------------------------------------
  // SOFT DELETE ENTRY
  // ------------------------------------------------------------

  Future<void> softDeleteEntry(String id) async {
    await (database.update(database.localUdhaarEntries)
          ..where((tbl) => tbl.id.equals(id)))
        .write(
      LocalUdhaarEntriesCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ------------------------------------------------------------
  // RESTORE ENTRY
  // ------------------------------------------------------------

  Future<void> restoreEntry(String id) async {
    await (database.update(database.localUdhaarEntries)
          ..where((tbl) => tbl.id.equals(id)))
        .write(
      LocalUdhaarEntriesCompanion(
        isDeleted: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ------------------------------------------------------------
  // GET DELETED ENTRIES
  // ------------------------------------------------------------

  Future<List<LocalUdhaarEntry>> getDeletedEntries(
    String userId,
  ) {
    return (database.select(database.localUdhaarEntries)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.isDeleted.equals(true),
          ))
        .get();
  }

  // ------------------------------------------------------------
  // PERMANENT DELETE
  // ------------------------------------------------------------

  Future<void> permanentDeleteEntry(String id) async {
    await (database.delete(database.localUdhaarEntries)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  // ------------------------------------------------------------
  // DELETE ALL ENTRIES FOR A USER
  // ------------------------------------------------------------

  Future<void> deleteAllEntries(String userId) async {
    await (database.delete(database.localUdhaarEntries)
          ..where((tbl) => tbl.userId.equals(userId)))
        .go();
  }
}