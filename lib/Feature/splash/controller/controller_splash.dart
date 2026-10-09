import 'package:expense_mate/Feature/onboarding/view/onboarding_view.dart';
import 'package:expense_mate/Feature/onboarding/controller/onboarding_controller.dart';
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

      final destination =
          user != null ? AppRoutes.home : AppRoutes.login;

      // Onboarding runs once per install, before anything else. The
      // destination is passed along so onboarding does not have to know
      // whether the user is signed in.
      if (!OnboardingController.hasSeen) {
        Get.offAllNamed(
          AppRoutes.onboarding,
          arguments: {OnboardingView.argNextRoute: destination},
        );
        return;
      }

      Get.offAllNamed(destination);
    });
  }
}