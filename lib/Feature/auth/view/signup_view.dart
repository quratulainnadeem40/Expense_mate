import 'package:expense_mate/Core/theme/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/auth_controller.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF080808)
          : const Color(0xFFF6F7F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Image.asset(
                  'assets/expense_mate.png',
                  height: 80,
                  width: 80,
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  'Create an account to manage your expenses',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 35),

              Text(
                'Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              AuthTextField(
                controller: controller.nameController,
                hintText: 'Enter your name',
                prefixIcon: Icons.person_outline,
              ),

              const SizedBox(height: 20),

              Text(
                'Email',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              AuthTextField(
                controller: controller.emailController,
                hintText: 'Enter your email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              Text(
                'Password',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              Obx(
                () => AuthTextField(
                  controller: controller.passwordController,
                  hintText: 'Create a password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: controller.obscurePassword.value,
                  suffixIcon: IconButton(
                    onPressed: controller.togglePasswordVisibility,
                    icon: Icon(
                      controller.obscurePassword.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: isDark ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Obx(
                () => AuthButton(
                  text: 'Create Account',
                  isLoading: controller.isLoading.value,
                  onPressed: controller.signUp,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}