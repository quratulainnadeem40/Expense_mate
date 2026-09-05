import 'dart:async';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToHome();
  }

  void _navigateToHome() {
    // 3 seconds timer ke baad Home/Dashboard screen par navigate karega
    Timer(const Duration(seconds: 3), () {
      Get.offAllNamed('/home'); // Apne home route ka exact name yahan add karein
    });
  }
}