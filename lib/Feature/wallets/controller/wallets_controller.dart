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
      print('Load wallets error: ${e.message}');
    } catch (e) {
      print('Load wallets error: $e');
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
      print('Add wallet error: User is not logged in.');
      return;
    }

    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      print('Add wallet error: Wallet name is empty.');
      return;
    }

    if (balance < 0) {
      print('Add wallet error: Balance cannot be negative.');
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
    } on PostgrestException catch (e) {
      print('Add wallet error: ${e.message}');
    } catch (e) {
      print('Add wallet error: $e');
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
      print('Update wallet error: User is not logged in.');
      return;
    }

    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      print('Update wallet error: Wallet name is empty.');
      return;
    }

    if (balance < 0) {
      print('Update wallet error: Balance cannot be negative.');
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
    } on PostgrestException catch (e) {
      print('Update wallet error: ${e.message}');
    } catch (e) {
      print('Update wallet error: $e');
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
      print('Change balance error: User is not logged in.');
      return;
    }

    try {
      isLoading.value = true;

      final wallet = wallets.firstWhere(
        (wallet) => wallet.id == walletId,
      );

      final newBalance = wallet.balance + amount;

      if (newBalance < 0) {
        print('Change balance error: Wallet balance cannot be negative.');
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
      print('Change balance error: Wallet not found.');
    } on PostgrestException catch (e) {
      print('Change balance error: ${e.message}');
    } catch (e) {
      print('Change balance error: $e');
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
      print('Delete wallet error: User is not logged in.');
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
    } on PostgrestException catch (e) {
      print('Delete wallet error: ${e.message}');
    } catch (e) {
      print('Delete wallet error: $e');
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
}