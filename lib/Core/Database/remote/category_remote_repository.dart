import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryRemoteRepository {
  final SupabaseClient supabase;

  CategoryRemoteRepository(this.supabase);

  // ================================
  // GET ALL CATEGORIES
  // ================================
  Future<List<Map<String, dynamic>>> getCategories(String userId) async {
    try {
      final response = await supabase
          .from('categories')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('================================');
      print('SUPABASE GET CATEGORIES ERROR');
      print(e);
      print('================================');

      rethrow;
    }
  }

  // ================================
  // GET CATEGORY BY ID
  // ================================
  Future<Map<String, dynamic>?> getCategoryById(
    String categoryId,
  ) async {
    try {
      final response = await supabase
          .from('categories')
          .select()
          .eq('id', categoryId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('================================');
      print('SUPABASE GET CATEGORY ERROR');
      print(e);
      print('================================');

      rethrow;
    }
  }

  // ================================
  // INSERT CATEGORY
  // ================================
  Future<void> insertCategory(
    Map<String, dynamic> category,
  ) async {
    try {
      print('================================');
      print('SUPABASE CATEGORY INSERT START');
      print('Payload: $category');
      print('================================');

      final response = await supabase
          .from('categories')
          .insert(category)
          .select();

      print('================================');
      print('SUPABASE CATEGORY INSERT RESPONSE');
      print(response);
      print('================================');
    } catch (e, stackTrace) {
      print('================================');
      print('SUPABASE CATEGORY INSERT ERROR');
      print(e);
      print('STACK TRACE:');
      print(stackTrace);
      print('================================');

      rethrow;
    }
  }

  // ================================
  // UPDATE CATEGORY
  // ================================
  Future<void> updateCategory(
    String categoryId,
    Map<String, dynamic> category,
  ) async {
    try {
      await supabase
          .from('categories')
          .update(category)
          .eq('id', categoryId);

      print('================================');
      print('SUPABASE CATEGORY UPDATED');
      print('ID: $categoryId');
      print('================================');
    } catch (e, stackTrace) {
      print('================================');
      print('SUPABASE CATEGORY UPDATE ERROR');
      print(e);
      print(stackTrace);
      print('================================');

      rethrow;
    }
  }

  // ================================
  // DELETE CATEGORY
  // ================================
  Future<void> deleteCategory(
    String categoryId,
  ) async {
    try {
      await supabase
          .from('categories')
          .delete()
          .eq('id', categoryId);

      print('================================');
      print('SUPABASE CATEGORY DELETED');
      print('ID: $categoryId');
      print('================================');
    } catch (e, stackTrace) {
      print('================================');
      print('SUPABASE CATEGORY DELETE ERROR');
      print(e);
      print(stackTrace);
      print('================================');

      rethrow;
    }
  }
}