
import 'package:expense_mate/Core/routes/app_routes.dart';
import 'package:expense_mate/Core/theme/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/auth_controller.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordView extends GetView<AuthController> {
  const ForgotPasswordView({super.key});

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
              // ==================================================
              // BACK ARROW
              // ==================================================

              IconButton(
                onPressed: () {
                  Get.offNamed(AppRoutes.login);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),

              const SizedBox(height: 45),

              Center(
                child: Icon(
                  Icons.lock_reset_rounded,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 28),

              Center(
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Text(
                  'Enter your email and we will send you a link to reset your password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: isDark ? Colors.white70 : Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 40),

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

              const SizedBox(height: 28),

              Obx(
                () => AuthButton(
                  text: 'Send Reset Link',
                  isLoading: controller.isLoading.value,
                  onPressed: () {
                    controller.resetPassword(
                      controller.emailController.text,
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // BACK TO LOGIN
              // ==================================================

              Center(
                child: TextButton(
                  onPressed: () {
                    Get.offNamed(AppRoutes.login);
                  },
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

