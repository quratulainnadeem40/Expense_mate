import 'dart:async';

import 'package:expense_mate/Core/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    _checkAuthentication();
  }

  void _checkAuthentication() {
    Timer(const Duration(seconds: 3), () {
      final user = _supabase.auth.currentUser;

      if (user != null) {
        // User is already logged in
        Get.offAllNamed(AppRoutes.home);
      } else {
        // User is not logged in
        Get.offAllNamed(AppRoutes.login);
      }
    });
  }
}