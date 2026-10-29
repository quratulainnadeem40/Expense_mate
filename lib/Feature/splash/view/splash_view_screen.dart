import 'package:expense_mate/Feature/splash/controller/controller_splash.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<SplashController>();

    return Scaffold(
      body: SizedBox.expand(
        child: Image.asset(
          'assets/expense_mate.png', // Apni image ka exact path
          fit: BoxFit.cover, // Yeh image ko poori screen par stretch bina distortion ke fit kar dega
        ),
      ),
    );
  }
}