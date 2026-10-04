import 'package:supabase_flutter/supabase_flutter.dart';

class WalletRemoteRepository {
  final SupabaseClient supabase;

  WalletRemoteRepository(this.supabase);

  Future<List<Map<String, dynamic>>> getWallets(
    String userId,
  ) async {
    final response = await supabase
        .from('wallets')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getWalletById(
    String walletId,
  ) async {
    final response = await supabase
        .from('wallets')
        .select()
        .eq('id', walletId)
        .maybeSingle();

    return response;
  }

  Future<void> insertWallet(
    Map<String, dynamic> wallet,
  ) async {
    await supabase
        .from('wallets')
        .insert(wallet);
  }

  Future<void> updateWallet(
    String walletId,
    Map<String, dynamic> wallet,
  ) async {
    await supabase
        .from('wallets')
        .update(wallet)
        .eq('id', walletId);
  }

 Future<void> deleteWallet(
  String walletId,
) async {
  await supabase
      .from('wallets')
      .delete()
      .eq('id', walletId);
}
}