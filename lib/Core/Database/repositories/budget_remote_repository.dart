import 'package:supabase_flutter/supabase_flutter.dart';

class BudgetRemoteRepository {
  final SupabaseClient supabase;

  BudgetRemoteRepository(this.supabase);

  /// Get all budgets for a user.
  Future<List<Map<String, dynamic>>> getBudgets(String userId) async {
    try {
      final response = await supabase
          .from('budgets')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      print('SUPABASE BUDGET FETCH ERROR: $e');
      print(stackTrace);
      rethrow;
    }
  }

  /// Get one budget by ID.
  Future<Map<String, dynamic>?> getBudgetById(String budgetId) async {
    try {
      final response = await supabase
          .from('budgets')
          .select()
          .eq('id', budgetId)
          .maybeSingle();

      return response;
    } catch (e, stackTrace) {
      print('SUPABASE BUDGET GET BY ID ERROR: $e');
      print(stackTrace);
      rethrow;
    }
  }

  /// Insert a budget.
  Future<void> insertBudget(Map<String, dynamic> budget) async {
    try {
      print('SUPABASE BUDGET INSERT START');
      print('Payload: $budget');

      final response = await supabase
          .from('budgets')
          .insert(budget)
          .select();

      print('SUPABASE BUDGET INSERT RESPONSE');
      print(response);
    } catch (e, stackTrace) {
      print('SUPABASE BUDGET INSERT ERROR: $e');
      print(stackTrace);
      rethrow;
    }
  }

  /// Update a budget.
  Future<void> updateBudget(
    String budgetId,
    Map<String, dynamic> budget,
  ) async {
    try {
      print('SUPABASE BUDGET UPDATE START');
      print('Budget ID: $budgetId');
      print('Payload: $budget');

      await supabase
          .from('budgets')
          .update(budget)
          .eq('id', budgetId);

      print('SUPABASE BUDGET UPDATE SUCCESS');
    } catch (e, stackTrace) {
      print('SUPABASE BUDGET UPDATE ERROR: $e');
      print(stackTrace);
      rethrow;
    }
  }

  /// Delete a budget from Supabase.
  Future<void> deleteBudget(String budgetId) async {
    try {
      print('SUPABASE BUDGET DELETE START');
      print('Budget ID: $budgetId');

      await supabase
          .from('budgets')
          .delete()
          .eq('id', budgetId);

      print('SUPABASE BUDGET DELETE SUCCESS');
    } catch (e, stackTrace) {
      print('SUPABASE BUDGET DELETE ERROR: $e');
      print(stackTrace);
      rethrow;
    }
  }
}