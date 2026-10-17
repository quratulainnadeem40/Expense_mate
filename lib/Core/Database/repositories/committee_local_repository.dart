import 'package:drift/drift.dart';

import '../app_database.dart';

class CommitteeLocalRepository {
  final AppDatabase database;

  CommitteeLocalRepository(this.database);

  // ------------------------------------------------------------
  // GET ALL ACTIVE COMMITTEES
  // ------------------------------------------------------------

  Future<List<LocalCommittee>> getCommittees(String userId) {
    return (database.select(database.localCommittees)
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

  // ------------------------------------------------------------
  // GET COMMITTEE BY ID
  // ------------------------------------------------------------

  Future<LocalCommittee?> getCommitteeById(String id) {
    return (database.select(database.localCommittees)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  // ------------------------------------------------------------
  // INSERT COMMITTEE
  // ------------------------------------------------------------

  Future<void> insertCommittee(
    LocalCommitteesCompanion committee,
  ) async {
    await database.into(database.localCommittees).insert(committee);
  }

  // ------------------------------------------------------------
  // UPDATE COMMITTEE
  // ------------------------------------------------------------

  Future<void> updateCommittee(
    String id,
    LocalCommitteesCompanion committee,
  ) async {
    await (database.update(database.localCommittees)
          ..where((tbl) => tbl.id.equals(id)))
        .write(committee);
  }

  // ------------------------------------------------------------
  // SOFT DELETE COMMITTEE
  // ------------------------------------------------------------

  Future<void> softDeleteCommittee(String id) async {
    await (database.update(database.localCommittees)
          ..where((tbl) => tbl.id.equals(id)))
        .write(
      LocalCommitteesCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ------------------------------------------------------------
  // RESTORE COMMITTEE
  // ------------------------------------------------------------

  Future<void> restoreCommittee(String id) async {
    await (database.update(database.localCommittees)
          ..where((tbl) => tbl.id.equals(id)))
        .write(
      LocalCommitteesCompanion(
        isDeleted: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ------------------------------------------------------------
  // GET DELETED COMMITTEES
  // ------------------------------------------------------------

  Future<List<LocalCommittee>> getDeletedCommittees(
    String userId,
  ) {
    return (database.select(database.localCommittees)
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

  Future<void> permanentDeleteCommittee(String id) async {
    await (database.delete(database.localCommittees)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  // ------------------------------------------------------------
  // DELETE ALL COMMITTEES FOR A USER
  // ------------------------------------------------------------

  Future<void> deleteAllCommittees(String userId) async {
    await (database.delete(database.localCommittees)
          ..where((tbl) => tbl.userId.equals(userId)))
        .go();
  }
}