
import 'package:expense_mate/Feature/Categories/model/categories_model.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoriesController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final categoryList = <CategoryModel>[].obs;
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
      return;
    }

    try {
      isLoading.value = true;

      final response = await _supabase
          .from('categories')
          .select()
          .eq('user_id', user.id)
          .order('name');

      final data = response as List;

      final categories = data
          .map(
            (item) => CategoryModel(
              id: item['id'].toString(),
              name: item['name'].toString(),
              icon: item['icon']?.toString() ?? 'category',
              colorValue: _parseColor(item['color']),
              isDefault: false,
              type: item['type']?.toString().toLowerCase() ?? 'expense',
            ),
          )
          .toList();

      categoryList.assignAll(categories);
    } on PostgrestException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Unable to load categories.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    final user = currentUser;

    if (user == null) {
      _showError('Please login first.');
      return;
    }

    try {
      isLoading.value = true;

      await _supabase.from('categories').insert({
        'user_id': user.id,
        'name': category.name,
        'icon': category.icon,
        'color': category.colorValue.toRadixString(16),
        'type': category.type,
      });

      await fetchCategories();

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
    if (value == null) {
      return 0xFF757575;
    }

    if (value is int) {
      return value;
    }

    final stringValue = value.toString();

    if (stringValue.startsWith('0x')) {
      return int.tryParse(stringValue) ?? 0xFF757575;
    }

    return int.tryParse(stringValue, radix: 16) ?? 0xFF757575;
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

