import 'package:expense_mate/Feature/pin/view/pin_setup_view.dart';
import 'package:expense_mate/Feature/pin/view/pin_lock_view.dart';
import 'package:expense_mate/Core/service/pin_service.dart';
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

      // Signed in: either ask for the PIN, or offer to create one.
      // Signed out: the login screen handles the PIN afterwards.
      String destination;

      if (user == null) {
        destination = AppRoutes.login;
      } else if (PinService.instance.isPinSet) {
        destination = AppRoutes.pinLock;
      } else {
        destination = AppRoutes.pinSetup;
      }

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

      if (destination == AppRoutes.pinLock) {
        PinService.instance.lock();
        Get.offAllNamed(
          AppRoutes.pinLock,
          arguments: {PinLockView.argNextRoute: AppRoutes.home},
        );
        return;
      }

      if (destination == AppRoutes.pinSetup) {
        Get.offAllNamed(
          AppRoutes.pinSetup,
          arguments: {
            PinSetupView.argNextRoute: AppRoutes.home,
            PinSetupView.argCanSkip: true,
          },
        );
        return;
      }

      Get.offAllNamed(destination);
    });
  }
}
