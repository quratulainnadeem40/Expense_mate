import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryRemoteRepository {
  final SupabaseClient supabase;

  CategoryRemoteRepository(this.supabase);

  Future<List<Map<String, dynamic>>> getCategories(
    String userId,
  ) async {
    final response = await supabase
        .from('categories')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getCategoryById(
    String categoryId,
  ) async {
    final response = await supabase
        .from('categories')
        .select()
        .eq('id', categoryId)
        .maybeSingle();

    return response;
  }

  Future<void> insertCategory(
    Map<String, dynamic> category,
  ) async {
    await supabase
        .from('categories')
        .insert(category);
  }

  Future<void> updateCategory(
    String categoryId,
    Map<String, dynamic> category,
  ) async {
    await supabase
        .from('categories')
        .update(category)
        .eq('id', categoryId);
  }

  Future<void> deleteCategory(
    String categoryId,
  ) async {
    await supabase
        .from('categories')
        .delete()
        .eq('id', categoryId);
  }
}