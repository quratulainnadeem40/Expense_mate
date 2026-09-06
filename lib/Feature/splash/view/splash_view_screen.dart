import 'package:expense_mate/Feature/splash/controller/controller_splash.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<SplashController>();

    return Scaffold(
      backgroundColor: const Color(0xFF030D26), // Dark background matching the image
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Image.asset(
            'assets/expense_mate.png', // Apni image ka exact path yahan dein
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}