import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/wallet_model.dart';

class WalletsController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final wallets = <WalletModel>[].obs;
  final isLoading = false.obs;

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

      final response = await _supabase
          .from('wallets')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: true);

      wallets.assignAll(
        (response as List)
            .map(
              (wallet) => WalletModel.fromMap(
                Map<String, dynamic>.from(wallet),
              ),
            )
            .toList(),
      );
    } on PostgrestException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Unable to load wallets. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWallets() async {
    await loadWallets();
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

      await _supabase.from('wallets').insert({
        'user_id': user.id,
        'name': trimmedName,
        'type': type,
        'balance': balance,
        'currency': currency,
      });

      await loadWallets();

      Get.back();

      Get.snackbar(
        'Success',
        'Wallet added successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on PostgrestException catch (e) {
      _showError(e.message);
    } catch (e) {
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

      await _supabase
          .from('wallets')
          .update({
            'name': trimmedName,
            'type': type,
            'balance': balance,
            'currency': currency,
          })
          .eq('id', walletId)
          .eq('user_id', user.id);

      await loadWallets();

      Get.back();

      Get.snackbar(
        'Success',
        'Wallet updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on PostgrestException catch (e) {
      _showError(e.message);
    } catch (e) {
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

      final wallet = wallets.firstWhere(
        (wallet) => wallet.id == walletId,
      );

      final newBalance = wallet.balance + amount;

      if (newBalance < 0) {
        _showError('Wallet balance cannot be negative.');
        return;
      }

      await _supabase
          .from('wallets')
          .update({
            'balance': newBalance,
          })
          .eq('id', walletId)
          .eq('user_id', user.id);

      await loadWallets();
    } on StateError {
      _showError('Wallet not found.');
    } on PostgrestException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Unable to change wallet balance.');
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

      await _supabase
          .from('wallets')
          .delete()
          .eq('id', walletId)
          .eq('user_id', user.id);

      wallets.removeWhere(
        (wallet) => wallet.id == walletId,
      );

      Get.snackbar(
        'Success',
        'Wallet deleted successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on PostgrestException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Unable to delete wallet. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================================
  // TOTAL BALANCE
  // ==========================================================

  double get totalBalance {
    return wallets.fold(
      0,
      (total, wallet) => total + wallet.balance,
    );
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}