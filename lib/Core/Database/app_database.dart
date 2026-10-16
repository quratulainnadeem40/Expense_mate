import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// ------------------------------------------------------------
/// TRANSACTIONS
/// ------------------------------------------------------------

class LocalTransactions extends Table {
  TextColumn get id => text()();

  TextColumn get userId => text()();

  TextColumn get walletId => text().nullable()();

  TextColumn get categoryId => text().nullable()();

  TextColumn get title => text()();

  RealColumn get amount => real()();

  TextColumn get type => text()();

  DateTimeColumn get transactionDate => dateTime()();

  TextColumn get note => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  IntColumn get version =>
      integer().withDefault(const Constant(1))();

  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// ------------------------------------------------------------
/// WALLETS
/// ------------------------------------------------------------

class LocalWallets extends Table {
  TextColumn get id => text()();

  TextColumn get userId => text()();

  TextColumn get name => text()();

  RealColumn get balance =>
      real().withDefault(const Constant(0.0))();

  TextColumn get currency =>
      text().withDefault(const Constant('PKR'))();

  TextColumn get type =>
      text().withDefault(const Constant('Cash'))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  IntColumn get version =>
      integer().withDefault(const Constant(1))();

  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// ------------------------------------------------------------
/// CATEGORIES
/// ------------------------------------------------------------

class LocalCategories extends Table {
  TextColumn get id => text()();

  TextColumn get userId => text()();

  TextColumn get name => text()();

  TextColumn get type => text()();

  TextColumn get icon => text().nullable()();

  TextColumn get color => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  IntColumn get version =>
      integer().withDefault(const Constant(1))();

  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// ------------------------------------------------------------
/// BUDGETS
/// ------------------------------------------------------------

class LocalBudgets extends Table {
  TextColumn get id => text()();

  TextColumn get userId => text()();

  TextColumn get categoryId => text().nullable()();

  TextColumn get name => text()();

  RealColumn get amount =>
      real().withDefault(const Constant(0.0))();

  RealColumn get spent =>
      real().withDefault(const Constant(0.0))();

  DateTimeColumn get startDate => dateTime()();

  DateTimeColumn get endDate => dateTime()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  IntColumn get version =>
      integer().withDefault(const Constant(1))();

  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// ------------------------------------------------------------
/// UDHAAR ENTRIES
/// ------------------------------------------------------------

class LocalUdhaarEntries extends Table {
  TextColumn get id => text()();

  TextColumn get userId => text()();

  TextColumn get personName => text()();

  TextColumn get phone =>
      text().withDefault(const Constant(''))();

  RealColumn get amount => real()();

  BoolColumn get isLent => boolean()();

  DateTimeColumn get entryDate => dateTime()();

  TextColumn get note =>
      text().withDefault(const Constant(''))();

  BoolColumn get isSettled =>
      boolean().withDefault(const Constant(false))();

  DateTimeColumn get settledOn => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  IntColumn get version =>
      integer().withDefault(const Constant(1))();

  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
/// ------------------------------------------------------------
/// COMMITTEES
/// ------------------------------------------------------------

class LocalCommittees extends Table {
  TextColumn get id => text()();

  TextColumn get userId => text()();

  TextColumn get name => text()();

  RealColumn get contribution => real()();

  IntColumn get memberCount => integer()();

  IntColumn get duration => integer()();

  TextColumn get unit =>
      text().withDefault(const Constant('Months'))();

  DateTimeColumn get startDate => dateTime()();

  DateTimeColumn get endingDate => dateTime()();

  TextColumn get allocationMode =>
      text().withDefault(const Constant('sequence'))();

  TextColumn get membersJson =>
      text().withDefault(const Constant('[]'))();

  TextColumn get paymentsJson =>
      text().withDefault(const Constant('[]'))();

  TextColumn get receivingSelectionsJson =>
      text().withDefault(const Constant('{}'))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  IntColumn get version =>
      integer().withDefault(const Constant(1))();

  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
/// ------------------------------------------------------------
/// SYNC QUEUE
/// ------------------------------------------------------------

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get userId => text()();

  TextColumn get entityTable => text()();

  TextColumn get recordId => text()();

  TextColumn get operation => text()();

  TextColumn get payload => text()();

  IntColumn get retryCount =>
      integer().withDefault(const Constant(0))();

  TextColumn get lastError => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {userId, entityTable, recordId},
      ];
}

/// ------------------------------------------------------------
/// DATABASE
/// ------------------------------------------------------------

@DriftDatabase(
  tables: [
    LocalTransactions,
    LocalWallets,
    LocalCategories,
    LocalBudgets,
    LocalUdhaarEntries,
    LocalCommittees,
    SyncQueue,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// ----------------------------------------------------------
  /// Schema version
  ///
  /// Version 1:
  /// Original database
  ///
  /// Version 2:
  /// SyncQueue unique key:
  /// userId + entityTable + recordId
  ///
  /// Version 3:
  /// Added LocalBudgets
  ///
  /// Version 4:
  /// Added Udhaar and Committees
  ///
  /// Version 5:
  /// Repair databases where the Udhaar table was not created in version 4
  /// ----------------------------------------------------------

 @override
int get schemaVersion => 5;

@override
MigrationStrategy get migration {
  return MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Version 1 -> Version 2: SyncQueue unique key.
      if (from < 2) {
        await _migrateSyncQueueToVersion2(m);
      }

      // Version 2 -> Version 3: Budgets table.
      if (from < 3) {
        await m.createTable(localBudgets);
      }

      // Version 3 -> Version 4: Udhaar and Committees tables.
      if (from < 4) {
        await m.createTable(localUdhaarEntries);
        await m.createTable(localCommittees);
      }

      // Repair version 4 databases that were marked upgraded without
      // successfully creating the Udhaar table.
      if (from < 5) {
        final udhaarTable = await customSelect(
          "SELECT name FROM sqlite_master "
          "WHERE type = 'table' AND name = ?",
          variables: [
            Variable.withString(localUdhaarEntries.actualTableName),
          ],
        ).get();

        if (udhaarTable.isEmpty) {
          await m.createTable(localUdhaarEntries);
        }
      }
    },
  );
}

  /// ----------------------------------------------------------
  /// MIGRATION: VERSION 1 → VERSION 2
  /// ----------------------------------------------------------

  Future<void> _migrateSyncQueueToVersion2(
    Migrator m,
  ) async {
    await customStatement(
      'ALTER TABLE sync_queue '
      'RENAME TO sync_queue_old',
    );

    await customStatement('''
      CREATE TABLE sync_queue (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        entity_table TEXT NOT NULL,
        record_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        payload TEXT NOT NULL,
        retry_count INTEGER NOT NULL DEFAULT 0,
        last_error TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        UNIQUE (
          user_id,
          entity_table,
          record_id
        )
      )
    ''');

    await customStatement('''
      INSERT INTO sync_queue (
        id,
        user_id,
        entity_table,
        record_id,
        operation,
        payload,
        retry_count,
        last_error,
        created_at,
        updated_at
      )
      SELECT
        id,
        user_id,
        entity_table,
        record_id,
        operation,
        payload,
        retry_count,
        last_error,
        created_at,
        updated_at
      FROM sync_queue_old
    ''');

    await customStatement(
      'DROP TABLE sync_queue_old',
    );
  }
}

/// ------------------------------------------------------------
/// DATABASE CONNECTION
/// ------------------------------------------------------------
///
/// Native:
///   expense_mate.sqlite
///
/// Web:
///   SQLite WASM + Drift Worker
///
/// Required web assets:
///   web/sqlite3.wasm
///   web/drift_worker.dart.js
///

DatabaseConnection _openConnection() {
  return driftDatabase(
    name: 'expense_mate',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.dart.js'),
    ),
  );
}
