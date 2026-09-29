import 'dart:async';
import 'dart:math';

import 'package:expense_mate/Core/database/repository_provider.dart';
import 'package:expense_mate/Core/database/sync/sync_manager.dart';
import 'package:expense_mate/Feature/wallets/model/wallet_model.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WalletsController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final wallets = <WalletModel>[].obs;
  final isLoading = false.obs;

  final RepositoryProvider _repositories = RepositoryProvider.instance;

  User? get currentUser => _supabase.auth.currentUser;

  @override
  void onInit() {
    super.onInit();
    loadWallets();
  }

  // ==========================================================
  // LOAD WALLETS
  // ==========================================================

  Future<void> loadWallets() async {
    final user = currentUser;

    if (user == null) {
      wallets.clear();
      return;
    }

    try {
      isLoading.value = true;

      // --------------------------------------------------------
      // 1. Load from local SQLite first.
      // --------------------------------------------------------

      await _loadFromLocal(user.id);

      // --------------------------------------------------------
      // 2. Try to synchronize with Supabase.
      // --------------------------------------------------------

      try {
        if (Get.isRegistered<SyncManager>()) {
          await Get.find<SyncManager>().sync();

          // ----------------------------------------------------
          // 3. Reload local data after synchronization.
          // ----------------------------------------------------

          await _loadFromLocal(user.id);
        }
      } catch (_) {
        // Offline/cloud failure.
        //
        // Local data remains available.
      }
    } catch (_) {
      _showError('Unable to load wallets. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWallets() async {
    await loadWallets();
  }

  // ==========================================================
  // LOAD FROM LOCAL DATABASE
  // ==========================================================

  Future<void> _loadFromLocal(String userId) async {
    final localWallets = await _repositories.wallets.getWallets(userId);

    final loadedWallets = localWallets.map((wallet) {
      return WalletModel(
        id: wallet.id,
        userId: wallet.userId,
        name: wallet.name,
        type: wallet.type,
        balance: wallet.balance,
        currency: wallet.currency,
        createdAt: wallet.createdAt,
      );
    }).toList();

    wallets.assignAll(loadedWallets);
  }

  // ==========================================================
  // ADD WALLET
  // ==========================================================

  Future<void> addWallet({
    required String name,
    required String type,
    double balance = 0,
    String currency = 'PKR',
  }) async {
    final user = currentUser;

    if (user == null) {
      _showError('Please login first.');
      return;
    }

    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      _showError('Please enter wallet name.');
      return;
    }

    if (balance < 0) {
      _showError('Balance cannot be negative.');
      return;
    }

    try {
      isLoading.value = true;

      final walletId = _generateUuid();

      // --------------------------------------------------------
      // LOCAL FIRST
      // --------------------------------------------------------

      await _repositories.walletSync.createWallet(
        userId: user.id,
        id: walletId,
        name: trimmedName,
        type: type,
        balance: balance,
        currency: currency,
      );

      // --------------------------------------------------------
      // Update UI immediately.
      // --------------------------------------------------------

      wallets.add(
        WalletModel(
          id: walletId,
          userId: user.id,
          name: trimmedName,
          type: type,
          balance: balance,
          currency: currency,
          createdAt: DateTime.now(),
        ),
      );

      // --------------------------------------------------------
      // Try cloud sync in background.
      // --------------------------------------------------------

      _syncInBackground();

      // Close Add Wallet screen/dialog.
      Get.back();
    } catch (_) {
      _showError('Unable to add wallet. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================================
  // UPDATE WALLET
  // ==========================================================

  Future<void> updateWallet({
    required String walletId,
    required String name,
    required String type,
    required double balance,
    required String currency,
  }) async {
    final user = currentUser;

    if (user == null) {
      _showError('Please login first.');
      return;
    }

    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      _showError('Please enter wallet name.');
      return;
    }

    if (balance < 0) {
      _showError('Balance cannot be negative.');
      return;
    }

    try {
      isLoading.value = true;

      final index = wallets.indexWhere((wallet) => wallet.id == walletId);

      if (index == -1) {
        _showError('Wallet not found.');
        return;
      }

      final existingWallet = wallets[index];

      // --------------------------------------------------------
      // LOCAL FIRST
      // --------------------------------------------------------

      await _repositories.walletSync.updateWallet(
        userId: user.id,
        id: walletId,
        name: trimmedName,
        type: type,
        balance: balance,
        currency: currency,
        createdAt: existingWallet.createdAt,
      );

      // --------------------------------------------------------
      // Update UI immediately.
      // --------------------------------------------------------

      wallets[index] = WalletModel(
        id: existingWallet.id,
        userId: existingWallet.userId,
        name: trimmedName,
        type: type,
        balance: balance,
        currency: currency,
        createdAt: existingWallet.createdAt,
      );

      // --------------------------------------------------------
      // Background sync.
      // --------------------------------------------------------

      _syncInBackground();

      Get.back();
    } catch (_) {
      _showError('Unable to update wallet. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================================
  // CHANGE BALANCE
  // ==========================================================

  Future<void> changeBalance({
    required String walletId,
    required double amount,
  }) async {
    final user = currentUser;

    if (user == null) {
      _showError('Please login first.');
      return;
    }

    try {
      isLoading.value = true;

      final index = wallets.indexWhere((wallet) => wallet.id == walletId);

      if (index == -1) {
        _showError('Wallet not found.');
        return;
      }

      final wallet = wallets[index];

      final newBalance = wallet.balance + amount;

      if (newBalance < 0) {
        _showError('Wallet balance cannot be negative.');
        return;
      }

      // --------------------------------------------------------
      // LOCAL FIRST
      // --------------------------------------------------------

      await _repositories.walletSync.updateWallet(
        userId: user.id,
        id: wallet.id,
        name: wallet.name,
        type: wallet.type,
        balance: newBalance,
        currency: wallet.currency,
        createdAt: wallet.createdAt,
      );

      // --------------------------------------------------------
      // Update UI immediately.
      // --------------------------------------------------------

      wallets[index] = WalletModel(
        id: wallet.id,
        userId: wallet.userId,
        name: wallet.name,
        type: wallet.type,
        balance: newBalance,
        currency: wallet.currency,
        createdAt: wallet.createdAt,
      );

      // --------------------------------------------------------
      // Background sync.
      // --------------------------------------------------------

      _syncInBackground();
    } catch (_) {
      _showError('Unable to change wallet balance.');
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================================
  // RESET ALL BALANCES
  // ==========================================================

  Future<void> resetAllBalances() async {
    final user = currentUser;

    if (user == null) {
      return;
    }

    if (wallets.isEmpty) {
      return;
    }

    try {
      isLoading.value = true;

      // --------------------------------------------------------
      // Update every wallet locally.
      //
      // Each update is queued separately, so every wallet will
      // eventually be synchronized with Supabase.
      // --------------------------------------------------------

      for (final wallet in wallets.toList()) {
        await _repositories.walletSync.updateWallet(
          userId: user.id,
          id: wallet.id,
          name: wallet.name,
          type: wallet.type,
          balance: 0,
          currency: wallet.currency,
          createdAt: wallet.createdAt,
        );
      }

      // --------------------------------------------------------
      // Update UI.
      // --------------------------------------------------------

      wallets.assignAll(
        wallets.map(
          (wallet) => WalletModel(
            id: wallet.id,
            userId: wallet.userId,
            name: wallet.name,
            type: wallet.type,
            balance: 0,
            currency: wallet.currency,
            createdAt: wallet.createdAt,
          ),
        ),
      );

      // --------------------------------------------------------
      // Background sync.
      // --------------------------------------------------------

      _syncInBackground();
    } catch (_) {
      _showError('Unable to reset wallet balances.');
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================================
  // DELETE WALLET
  // ==========================================================

  Future<void> deleteWallet(String walletId) async {
    final user = currentUser;

    if (user == null) {
      _showError('Please login first.');
      return;
    }

    try {
      isLoading.value = true;

      final exists = wallets.any((wallet) => wallet.id == walletId);

      if (!exists) {
        _showError('Wallet not found.');
        return;
      }

      // --------------------------------------------------------
      // LOCAL FIRST
      // --------------------------------------------------------

      await _repositories.walletSync.deleteWallet(
        userId: user.id,
        id: walletId,
      );

      // --------------------------------------------------------
      // Remove from UI immediately.
      // --------------------------------------------------------

      wallets.removeWhere((wallet) => wallet.id == walletId);

      // --------------------------------------------------------
      // Background sync.
      // --------------------------------------------------------

      _syncInBackground();
    } catch (_) {
      _showError('Unable to delete wallet. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================================
  // BACKGROUND SYNC
  // ==========================================================

  void _syncInBackground() {
    try {
      if (Get.isRegistered<SyncManager>()) {
        unawaited(Get.find<SyncManager>().sync());
      }
    } catch (_) {
      // Local operation is already stored safely.
      //
      // SyncManager will retry the queued operation later.
    }
  }

  // ==========================================================
  // TOTAL BALANCE
  // ==========================================================

  double get totalBalance {
    return wallets.fold(0, (total, wallet) => total + wallet.balance);
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  void _showError(String message) {
    // Intentionally no Get.snackbar().
    //
    // GetX snackbar previously caused:
    // LateInitializationError: Field '_animation'
    // has not been initialized.
    //
    // The controller stays UI-independent.
  }

  // ==========================================================
  // LOCAL UUID
  // ==========================================================

  String _generateUuid() {
    final random = Random();

    String hex(int count) {
      final bytes = List<int>.generate(count, (_) => random.nextInt(256));

      return bytes
          .map((value) => value.toRadixString(16).padLeft(2, '0'))
          .join();
    }

    final part1 = hex(4);
    final part2 = hex(2);

    final part3Bytes = List<int>.generate(2, (_) => random.nextInt(256));

    part3Bytes[0] = (part3Bytes[0] & 0x0f) | 0x40;

    final part3 = part3Bytes
        .map((value) => value.toRadixString(16).padLeft(2, '0'))
        .join();

    final part4Bytes = List<int>.generate(2, (_) => random.nextInt(256));

    part4Bytes[0] = (part4Bytes[0] & 0x3f) | 0x80;

    final part4 = part4Bytes
        .map((value) => value.toRadixString(16).padLeft(2, '0'))
        .join();

    final part5 = hex(6);

    return '$part1-$part2-$part3-$part4-$part5';
  }
}
