import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../Core/constants/app_keys.dart';
import '../model/wallet_model.dart';

class WalletsController extends GetxController {
  late Box walletBox;

  final wallets = <WalletModel>[].obs;
  final isLoading = false.obs;

  double get totalBalance {
    return wallets.fold(
      0.0,
      (sum, wallet) => sum + wallet.balance,
    );
  }

  @override
  void onInit() {
    super.onInit();

    walletBox = Hive.box(AppKeys.walletsBox);

    loadWallets();
  }

  // ==========================================================
  // LOAD
  // ==========================================================

  void loadWallets() {
    isLoading.value = true;

    final loadedWallets = walletBox.values.map((item) {
      return WalletModel.fromMap(
        Map<dynamic, dynamic>.from(item),
      );
    }).toList();

    wallets.assignAll(loadedWallets);

    isLoading.value = false;
  }

  // ==========================================================
  // ADD
  // ==========================================================

  Future<void> addWallet({
    required String name,
    required String type,
    required double balance,
    required String currency,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final wallet = WalletModel(
      id: id,
      name: name,
      type: type,
      balance: balance,
      currency: currency,
    );

    await walletBox.put(
      id,
      wallet.toMap(),
    );

    wallets.add(wallet);
  }

  // ==========================================================
  // UPDATE
  // ==========================================================

  Future<void> updateWallet(WalletModel wallet) async {
    await walletBox.put(
      wallet.id,
      wallet.toMap(),
    );

    final index = wallets.indexWhere(
      (item) => item.id == wallet.id,
    );

    if (index != -1) {
      wallets[index] = wallet;
      wallets.refresh();
    }
  }

  // ==========================================================
  // DELETE
  // ==========================================================

  Future<void> deleteWallet(String id) async {
    await walletBox.delete(id);

    wallets.removeWhere(
      (wallet) => wallet.id == id,
    );
  }

  // ==========================================================
  // CHANGE BALANCE
  // ==========================================================

  Future<void> changeBalance({
    required String walletId,
    required double amount,
  }) async {
    final index = wallets.indexWhere(
      (wallet) => wallet.id == walletId,
    );

    if (index == -1) return;

    final wallet = wallets[index];

    final updatedWallet = wallet.copyWith(
      balance: wallet.balance + amount,
    );

    await updateWallet(updatedWallet);
  }

  // ==========================================================
  // CLEAR
  // ==========================================================

  Future<void> clearWallets() async {
    await walletBox.clear();
    wallets.clear();
  }
}