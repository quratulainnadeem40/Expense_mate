import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expense_mate/Core/routes/app_routes.dart';

class AuthController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;

  User? get currentUser => _supabase.auth.currentUser;

  // ============================================================
  // SIGN UP
  // ============================================================

  Future<void> signUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty) {
      _showError('Please enter your name');
      return;
    }

    if (email.isEmpty) {
      _showError('Please enter your email');
      return;
    }

    if (password.isEmpty) {
      _showError('Please enter your password');
      return;
    }

    if (password.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    try {
      isLoading.value = true;

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
        },
      );

     if (response.user != null) {
  Get.snackbar(
    'Success',
    'Account created successfully',
    snackPosition: SnackPosition.BOTTOM,
  );

  Get.offAllNamed(AppRoutes.home);
}
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      _showError('Please enter your email');
      return;
    }

    if (password.isEmpty) {
      _showError('Please enter your password');
      return;
    }

    try {
      isLoading.value = true;

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        Get.snackbar(
          'Welcome',
          'Login successful',
          snackPosition: SnackPosition.BOTTOM,
        );

      Get.offAllNamed(AppRoutes.home);
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();

      Get.offAllNamed(AppRoutes.login);
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Unable to logout. Please try again.');
    }
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  Future<void> resetPassword(String email) async {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty) {
      _showError('Please enter your email');
      return;
    }

    try {
      isLoading.value = true;

      await _supabase.auth.resetPasswordForEmail(
        trimmedEmail,
      );

      Get.snackbar(
        'Email Sent',
        'Check your email for the password reset link.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // PASSWORD VISIBILITY
  // ============================================================

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();

    super.onClose();
  }
}