import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionRemoteRepository {
  final SupabaseClient supabase;

  TransactionRemoteRepository(this.supabase);

  Future<List<Map<String, dynamic>>> getTransactions(
    String userId,
  ) async {
    final response = await supabase
        .from('transactions')
        .select()
        .eq('user_id', userId)
        .order('transaction_date', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getTransactionById(
    String transactionId,
  ) async {
    final response = await supabase
        .from('transactions')
        .select()
        .eq('id', transactionId)
        .maybeSingle();

    return response;
  }

  Future<void> insertTransaction(
    Map<String, dynamic> transaction,
  ) async {
    await supabase
        .from('transactions')
        .insert(transaction);
  }

  Future<void> updateTransaction(
    String transactionId,
    Map<String, dynamic> transaction,
  ) async {
    await supabase
        .from('transactions')
        .update(transaction)
        .eq('id', transactionId);
  }

  Future<void> deleteTransaction(
    String transactionId,
  ) async {
    await supabase
        .from('transactions')
        .delete()
        .eq('id', transactionId);
  }
}