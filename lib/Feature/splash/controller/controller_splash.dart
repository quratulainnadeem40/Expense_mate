import 'dart:async';

import 'package:expense_mate/Core/routes/app_routes.dart';
import 'package:expense_mate/Core/service/pin_service.dart';
import 'package:expense_mate/Feature/onboarding/controller/onboarding_controller.dart';
import 'package:expense_mate/Feature/onboarding/view/onboarding_view.dart';
import 'package:expense_mate/Feature/pin/view/pin_lock_view.dart';
import 'package:expense_mate/Feature/pin/view/pin_setup_view.dart';
import 'package:flutter/material.dart';
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
    Timer(const Duration(seconds: 3), () async {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        _navigate(AppRoutes.login);
        return;
      }

      try {
        // Check PIN from Supabase for the current account.
        final hasPin = await PinService.instance.hasPinOnServer();

        if (hasPin) {
          PinService.instance.lock();

          _navigate(
            AppRoutes.pinLock,
            arguments: {
              PinLockView.argNextRoute: AppRoutes.home,
            },
          );
        } else {
          _navigate(
            AppRoutes.pinSetup,
            arguments: {
              PinSetupView.argNextRoute: AppRoutes.home,
              PinSetupView.argCanSkip: true,
            },
          );
        }
      } catch (e) {
        debugPrint('SPLASH PIN CHECK ERROR: $e');

        Get.offAllNamed(AppRoutes.login);

        Get.snackbar(
          'Connection Error',
          'Unable to check your PIN. Please login again when internet is available.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    });
  }

  void _navigate(
    String destination, {
    Map<String, dynamic>? arguments,
  }) {
    if (!OnboardingController.hasSeen) {
      Get.offAllNamed(
        AppRoutes.onboarding,
        arguments: {
          OnboardingView.argNextRoute: destination,
        },
      );
      return;
    }

    Get.offAllNamed(
      destination,
      arguments: arguments,
    );
  }
}