import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
  {entityTable, recordId},
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
    SyncQueue,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

/// ------------------------------------------------------------
/// DATABASE CONNECTION
/// ------------------------------------------------------------

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory =
        await getApplicationDocumentsDirectory();

    final file = File(
      p.join(
        directory.path,
        'expense_mate.sqlite',
      ),
    );

    return NativeDatabase.createInBackground(file);
  });
}