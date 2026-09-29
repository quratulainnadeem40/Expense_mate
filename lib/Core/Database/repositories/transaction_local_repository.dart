import 'package:drift/drift.dart';

import '../app_database.dart';

class TransactionLocalRepository {
  final AppDatabase database;

  TransactionLocalRepository(this.database);

  // ------------------------------------------------------------
  // GET ALL ACTIVE TRANSACTIONS
  // ------------------------------------------------------------

  Future<List<LocalTransaction>> getTransactions(
    String userId,
  ) {
    return (database.select(database.localTransactions)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.isDeleted.equals(false),
          )
          ..orderBy([
            (tbl) => OrderingTerm(
                  expression: tbl.transactionDate,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  // ------------------------------------------------------------
  // GET SINGLE TRANSACTION
  // ------------------------------------------------------------

  Future<LocalTransaction?> getTransactionById(
    String transactionId,
  ) {
    return (database.select(database.localTransactions)
          ..where(
            (tbl) => tbl.id.equals(transactionId),
          ))
        .getSingleOrNull();
  }

  // ------------------------------------------------------------
  // INSERT TRANSACTION
  // ------------------------------------------------------------

  Future<void> insertTransaction(
    LocalTransactionsCompanion transaction,
  ) async {
    await database
        .into(database.localTransactions)
        .insert(transaction);
  }

  // ------------------------------------------------------------
  // UPDATE TRANSACTION
  // ------------------------------------------------------------

  Future<bool> updateTransaction(
    String transactionId,
    LocalTransactionsCompanion transaction,
  ) async {
    return database
        .update(database.localTransactions)
        .replace(
          transaction.copyWith(
            id: Value(transactionId),
          ),
        );
  }

 

 // ------------------------------------------------------------
// SOFT DELETE TRANSACTION
// ------------------------------------------------------------

Future<int> softDeleteTransaction(
  String transactionId,
) async {
  return (database.update(database.localTransactions)
        ..where(
          (tbl) => tbl.id.equals(transactionId),
        ))
      .write(
    LocalTransactionsCompanion(
      isDeleted: const Value(true),
      updatedAt: Value(DateTime.now()),
    ),
  );
}

// ------------------------------------------------------------
// RESTORE TRANSACTION
// ------------------------------------------------------------

Future<int> restoreTransaction(
  String transactionId,
) async {
  return (database.update(database.localTransactions)
        ..where(
          (tbl) => tbl.id.equals(transactionId),
        ))
      .write(
    LocalTransactionsCompanion(
      isDeleted: const Value(false),
      updatedAt: Value(DateTime.now()),
    ),
  );
}
  // ------------------------------------------------------------
  // GET DELETED TRANSACTIONS
  // ------------------------------------------------------------

  Future<List<LocalTransaction>> getDeletedTransactions(
    String userId,
  ) {
    return (database.select(database.localTransactions)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.isDeleted.equals(true),
          ))
        .get();
  }

  // ------------------------------------------------------------
  // PERMANENT DELETE TRANSACTION
  // ------------------------------------------------------------

  Future<int> permanentlyDeleteTransaction(
    String transactionId,
  ) {
    return (database.delete(database.localTransactions)
          ..where(
            (tbl) => tbl.id.equals(transactionId),
          ))
        .go();
  }
}