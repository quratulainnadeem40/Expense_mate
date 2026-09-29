import 'app_database.dart';
import 'database_provider.dart';

import 'repositories/category_local_repository.dart';
import 'repositories/category_sync_repository.dart';
import 'repositories/sync_queue_repository.dart';
import 'repositories/transaction_local_repository.dart';
import 'repositories/transaction_sync_repository.dart';
import 'repositories/wallet_local_repository.dart';
import 'repositories/wallet_sync_repository.dart';

class RepositoryProvider {
  RepositoryProvider._();

  static final RepositoryProvider instance =
      RepositoryProvider._();

  // ---------------------------------------------------------------------------
  // DATABASE
  // ---------------------------------------------------------------------------

  AppDatabase get database =>
      DatabaseProvider.instance.database;

  // ---------------------------------------------------------------------------
  // LOCAL REPOSITORIES
  // ---------------------------------------------------------------------------

  TransactionLocalRepository get transactions =>
      TransactionLocalRepository(database);

  WalletLocalRepository get wallets =>
      WalletLocalRepository(database);

  CategoryLocalRepository get categories =>
      CategoryLocalRepository(database);

  SyncQueueRepository get syncQueue =>
      SyncQueueRepository(database);

  // ---------------------------------------------------------------------------
  // SYNC REPOSITORIES
  // ---------------------------------------------------------------------------

  TransactionSyncRepository get transactionSync =>
      TransactionSyncRepository(
        localRepository: transactions,
        syncQueue: syncQueue,
      );

  WalletSyncRepository get walletSync =>
      WalletSyncRepository(
        localRepository: wallets,
        syncQueue: syncQueue,
      );

  CategorySyncRepository get categorySync =>
      CategorySyncRepository(
        localRepository: categories,
        syncQueue: syncQueue,
      );
}