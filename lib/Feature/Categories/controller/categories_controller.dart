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

      final data = response;
      final Map<String, int> countsMap = {};
      final seenNames = <String>{};
      final categories = <CategoryModel>[];

      for (final item in data) {
        final rawName = item['name']?.toString() ?? '';

        // Normalize aggressively: trim whitespace, convert to lowercase,
        // and collapse multiple internal spaces into one
        final normalizedName = rawName.trim().toLowerCase().replaceAll(
          RegExp(r'\s+'),
          ' ',
        );

        // Skip if this normalized name has already been processed
        if (seenNames.contains(normalizedName)) {
          continue;
        }
        seenNames.add(normalizedName);

        final String catId = item['id'].toString();
        int count = 0;

        final transactions = item['transactions'];
        if (transactions is List && transactions.isNotEmpty) {
          count = (transactions.first['count'] as num?)?.toInt() ?? 0;
        }

        countsMap[catId] = count;

        categories.add(
          CategoryModel(
            id: catId,
            name: rawName, // Keep original casing/formatting for display
            icon: item['icon']?.toString() ?? 'category',
            colorValue: _parseColor(item['color']),
            isDefault: false,
            type: item['type']?.toString().toLowerCase() ?? 'expense',
          ),
        );
      }

      categories.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

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

  Future<void> addCategory(CategoryModel category) async {
    final user = currentUser;

    if (user == null) {
      _showError('Please login first.');
      return;
    }

    try {
      isLoading.value = true;

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
        name: response['name']?.toString() ?? category.name,
        icon: response['icon']?.toString() ?? category.icon,
        colorValue: _parseColor(response['color']),
        isDefault: false,
        type: response['type']?.toString().toLowerCase() ?? 'expense',
      );

      categoryCounts[newId] = 0;
      categoryList.add(newCategory);

      categoryList.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

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

  Future<void> deleteCategory(String id) async {
    await deleteCategories([id]);
  }

  Future<void> deleteCategories(List<String> ids) async {
    final user = currentUser;

    if (user == null) {
      _showError('Please login first.');
      return;
    }

    if (ids.isEmpty) {
      return;
    }

    try {
      isLoading.value = true;

      await _supabase
          .from('categories')
          .delete()
          .inFilter('id', ids)
          .eq('user_id', user.id);

      categoryList.removeWhere((category) => ids.contains(category.id));
      for (final id in ids) {
        categoryCounts.remove(id);
      }

      Get.snackbar(
        'Deleted',
        ids.length == 1
            ? 'Category deleted successfully'
            : '${ids.length} categories deleted successfully',
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
    if (value == null) {
      return 0xFF757575;
    }

    if (value is int) {
      return value;
    }

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
