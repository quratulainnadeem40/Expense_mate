import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/onboarding_controller.dart';

const Color _green = Color(0xFF2EA44F);
const Color _greenDeep = Color(0xFF1B7A38);

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  /// Where to go once onboarding is done. Passed in by whoever opens
  /// this screen, so onboarding does not need to know about auth.
  static const String argNextRoute = 'nextRoute';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final background = isDark ? const Color(0xFF101010) : Colors.white;
    final primaryText =
        isDark ? Colors.white : const Color(0xFF1C1C1C);
    final secondaryText =
        isDark ? Colors.white70 : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Obx(() {
          final index = controller.pageIndex.value;

          return Column(
            children: [
              // ---------------------------------------------- back
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    if (index > 0)
                      IconButton(
                        onPressed: controller.back,
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: secondaryText,
                        ),
                      ),
                  ],
                ),
              ),

              // ---------------------------------------------- page
              Expanded(
                child: _pageFor(
                  index,
                  isDark: isDark,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                ),
              ),

              // ---------------------------------------------- dots
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    OnboardingController.pageCount,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == index ? 22 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: i == index
                            ? _green
                            : (isDark ? Colors.white24 : Colors.black12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),

              // ---------------------------------------------- button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => _onPrimaryTap(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      controller.isLastPage ? 'Get started' : 'Next',
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _onPrimaryTap(BuildContext context) async {
    if (!controller.isLastPage) {
      controller.next();
      return;
    }

    await controller.finish();

    final next = Get.arguments is Map
        ? (Get.arguments as Map)[argNextRoute] as String?
        : null;

    Get.offAllNamed(next ?? '/home');
  }

  Widget _pageFor(
    int index, {
    required bool isDark,
    required Color primaryText,
    required Color secondaryText,
  }) {
    switch (index) {
      case 0:
        return _LanguagePage(
          isDark: isDark,
          primaryText: primaryText,
          secondaryText: secondaryText,
        );

      case 1:
        return _MessagePage(
          icon: Icons.phonelink_lock_rounded,
          title: 'Your money, on your phone',
          body: 'Every entry is stored on this device first and synced '
              'to your account, so the app keeps working even when the '
              'signal does not.',
          primaryText: primaryText,
          secondaryText: secondaryText,
        );

      case 2:
        return _MessagePage(
          icon: Icons.bolt_rounded,
          title: 'An entry takes three taps',
          body: 'Tap the green button, type the amount, pick a category '
              'and wallet. Budgets, goals and reports fill themselves in '
              'from there.',
          primaryText: primaryText,
          secondaryText: secondaryText,
        );

      default:
        return _CurrencyPage(
          isDark: isDark,
          primaryText: primaryText,
          secondaryText: secondaryText,
        );
    }
  }
}

// =====================================================================
// PAGE 1 - LANGUAGE
// =====================================================================
class _LanguagePage extends GetView<OnboardingController> {
  const _LanguagePage({
    required this.isDark,
    required this.primaryText,
    required this.secondaryText,
  });

  final bool isDark;
  final Color primaryText;
  final Color secondaryText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose your language',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: primaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'You can change it later in Settings.',
                style: TextStyle(fontSize: 13, color: secondaryText),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        Expanded(
          child: Obx(() {
            final selected = controller.selectedLanguage.value;

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: OnboardingController.languages.length,
              itemBuilder: (context, i) {
                final language = OnboardingController.languages[i];
                final code = language.code.toLowerCase();
                final isActive = code == selected;

                return _PickRow(
                  isDark: isDark,
                  isActive: isActive,
                  badge: language.code,
                  title: language.nativeName,
                  subtitle: language.englishName,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  onTap: () => controller.setLanguage(code),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

// =====================================================================
// PAGES 2 AND 3 - PLAIN MESSAGE
// =====================================================================
class _MessagePage extends StatelessWidget {
  const _MessagePage({
    required this.icon,
    required this.title,
    required this.body,
    required this.primaryText,
    required this.secondaryText,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color primaryText;
  final Color secondaryText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE6F3E9), Color(0xFFCDE8D5)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 52, color: _greenDeep),
          ),

          const SizedBox(height: 32),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: primaryText,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// PAGE 4 - CURRENCY
// =====================================================================
class _CurrencyPage extends GetView<OnboardingController> {
  const _CurrencyPage({
    required this.isDark,
    required this.primaryText,
    required this.secondaryText,
  });

  final bool isDark;
  final Color primaryText;
  final Color secondaryText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose your currency',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: primaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Every amount in the app is shown in this currency.',
                style: TextStyle(fontSize: 13, color: secondaryText),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        Expanded(
          child: Obx(() {
            final selected = controller.selectedCurrency.value;

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: OnboardingController.currencies.length,
              itemBuilder: (context, i) {
                final currency = OnboardingController.currencies[i];
                final isActive = currency.code == selected;

                return _PickRow(
                  isDark: isDark,
                  isActive: isActive,
                  badge: currency.symbol,
                  title: currency.name,
                  subtitle: currency.code,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  onTap: () => controller.setCurrency(currency.code),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

// =====================================================================
// SHARED ROW
// =====================================================================
class _PickRow extends StatelessWidget {
  const _PickRow({
    required this.isDark,
    required this.isActive,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.primaryText,
    required this.secondaryText,
    required this.onTap,
  });

  final bool isDark;
  final bool isActive;
  final String badge;
  final String title;
  final String subtitle;
  final Color primaryText;
  final Color secondaryText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? _green.withOpacity(isDark ? 0.16 : 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive
                    ? _green
                    : (isDark ? Colors.white12 : Colors.black12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white10
                        : Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    badge,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: badge.length > 2 ? 11.5 : 14,
                      fontWeight: FontWeight.w700,
                      color: isActive ? _greenDeep : secondaryText,
                    ),
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: primaryText,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),

                if (isActive)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 21,
                    color: _green,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
