import 'package:drift/drift.dart';

import '../app_database.dart';

class WalletLocalRepository {
  final AppDatabase database;

  WalletLocalRepository(this.database);

  Future<List<LocalWallet>> getWallets(
    String userId,
  ) {
    return (database.select(database.localWallets)
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

  Future<LocalWallet?> getWalletById(
    String walletId,
  ) {
    return (database.select(database.localWallets)
          ..where(
            (tbl) => tbl.id.equals(walletId),
          ))
        .getSingleOrNull();
  }

  Future<void> insertWallet(
    LocalWalletsCompanion wallet,
  ) async {
    await database
        .into(database.localWallets)
        .insert(wallet);
  }

  Future<bool> updateWallet(
    String walletId,
    LocalWalletsCompanion wallet,
  ) async {
    return database
        .update(database.localWallets)
        .replace(
          wallet.copyWith(
            id: Value(walletId),
          ),
        );
  }

  Future<int> softDeleteWallet(
    String walletId,
  ) async {
    return (database.update(database.localWallets)
          ..where(
            (tbl) => tbl.id.equals(walletId),
          ))
        .write(
      LocalWalletsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> restoreWallet(
    String walletId,
  ) async {
    return (database.update(database.localWallets)
          ..where(
            (tbl) => tbl.id.equals(walletId),
          ))
        .write(
      LocalWalletsCompanion(
        isDeleted: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<LocalWallet>> getDeletedWallets(
    String userId,
  ) {
    return (database.select(database.localWallets)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.isDeleted.equals(true),
          ))
        .get();
  }

  Future<int> permanentlyDeleteWallet(
    String walletId,
  ) {
    return (database.delete(database.localWallets)
          ..where(
            (tbl) => tbl.id.equals(walletId),
          ))
        .go();
  }
}