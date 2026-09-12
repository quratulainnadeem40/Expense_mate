import 'package:expense_mate/Feature/Categories/model/categories_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoriesController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final categoryList = <CategoryModel>[].obs;
  final categoryCounts = <String, int>{}.obs;
  final isLoading = false.obs;

  User? get currentUser => _supabase.auth.currentUser;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  // Categories & Transaction Counts Fetch
  Future<void> fetchCategories() async {
    final user = currentUser;

    if (user == null) {
      categoryList.clear();
      categoryCounts.clear();
      return;
    }

    try {
      isLoading.value = true;

    final response = await _supabase
    .from('categories')
    .select('*, transactions(count)')
    .eq('user_id', user.id)
    .order('name');

      final data = response as List;
      final Map<String, int> countsMap = {};

      final categories = data.map((item) {
        final String catId = item['id'].toString();

        int count = 0;
       if (item['transactions'] != null &&
    (item['transactions'] as List).isNotEmpty) {
  count = item['transactions'][0]['count'] ?? 0;
}
        countsMap[catId] = count;

        return CategoryModel(
          id: catId,
          name: item['name'].toString(),
          icon: item['icon']?.toString() ?? 'category',
          colorValue: _parseColor(item['color']),
          isDefault: false,
          type: item['type']?.toString().toLowerCase() ?? 'expense',
        );
      }).toList();

      categoryCounts.assignAll(countsMap);
      categoryList.assignAll(categories);
    } on PostgrestException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Unable to load categories.');
    } finally {
      isLoading.value = false;
    }
  }

  int getCategoryCount(String categoryId) {
    return categoryCounts[categoryId] ?? 0;
  }

  // Add Category (Fixed Foreign Key / Insert Error)
  Future<void> addCategory(CategoryModel category) async {
    final user = currentUser;

    if (user == null) {
      _showError('Please login first.');
      return;
    }

    try {
      isLoading.value = true;

      // Single insert query without schema join error
      final response = await _supabase
          .from('categories')
          .insert({
            'user_id': user.id,
            'name': category.name,
            'icon': category.icon,
            'color': category.colorValue.toRadixString(16).padLeft(8, '0'),
            'type': category.type,
          })
          .select()
          .single();

      final String newId = response['id'].toString();
      final newCategory = CategoryModel(
        id: newId,
        name: response['name'].toString(),
        icon: response['icon']?.toString() ?? 'category',
        colorValue: _parseColor(response['color']),
        isDefault: false,
        type: response['type']?.toString().toLowerCase() ?? 'expense',
      );

      categoryCounts[newId] = 0;
      categoryList.add(newCategory);
      categoryList.sort((a, b) => a.name.compareTo(b.name));

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Success',
        'Category added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on PostgrestException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Unable to add category.');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete Category
  Future<void> deleteCategory(String id) async {
    final user = currentUser;

    if (user == null) {
      _showError('Please login first.');
      return;
    }

    try {
      isLoading.value = true;

      await _supabase
          .from('categories')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id);

      categoryList.removeWhere((cat) => cat.id == id);
      categoryCounts.remove(id);

      Get.snackbar(
        'Deleted',
        'Category deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on PostgrestException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Unable to delete category.');
    } finally {
      isLoading.value = false;
    }
  }

  int _parseColor(dynamic value) {
    if (value == null) return 0xFF757575;
    if (value is int) return value;

    String hex = value.toString().replaceAll('#', '').trim();

    if (hex.startsWith('0x')) {
      hex = hex.substring(2);
    }
    if (hex.length == 6) {
      hex = 'FF$hex';
    }

    return int.tryParse(hex, radix: 16) ?? 0xFF757575;
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      snackStyle: SnackStyle.FLOATING,
      backgroundColor: Colors.redAccent.withOpacity(0.8),
      colorText: Colors.white,
    );
  }
}