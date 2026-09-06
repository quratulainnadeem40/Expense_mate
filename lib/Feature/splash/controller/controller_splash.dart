import 'dart:async';
import 'package:get/get.dart';
import '../../Home/view/main_screen.dart'; // Exact path check kar lein

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToHome();
  }

  void _navigateToHome() {
    // 3 seconds timer ke baad MainScreen par navigate hoga
    Timer(const Duration(seconds: 3), () {
      Get.offAll(() => const MainScreen());
    });
  }
}