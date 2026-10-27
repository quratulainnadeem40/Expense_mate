import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../Core/constants/app_keys.dart';
import '../../settings/controller/settings_controller.dart';

/// One language the user can pick on the first page.
class OnboardingLanguage {
  const OnboardingLanguage({
    required this.code,
    required this.nativeName,
    required this.englishName,
  });

  /// Shown in the small square badge, e.g. EN.
  final String code;

  /// Written the way a speaker of that language would read it.
  final String nativeName;

  final String englishName;
}

/// One currency the user can pick on the last page.
class OnboardingCurrency {
  const OnboardingCurrency({
    required this.code,
    required this.name,
    required this.symbol,
  });

  final String code;
  final String name;
  final String symbol;
}

class OnboardingController extends GetxController {
  static const String seenKey = 'onboarding_seen';
  static const String languageKey = 'app_language';

  final pageIndex = 0.obs;

  final selectedLanguage = 'en'.obs;
  final selectedCurrency = 'PKR'.obs;

  /// Four pages: language, two short explanations, then currency.
  static const int pageCount = 4;

  /// Urdu first because most of the people using this app read it.
  static const List<OnboardingLanguage> languages = [
    OnboardingLanguage(
      code: 'UR',
      nativeName: 'اردو',
      englishName: 'Urdu',
    ),
    OnboardingLanguage(
      code: 'EN',
      nativeName: 'English',
      englishName: 'English',
    ),
    OnboardingLanguage(
      code: 'PS',
      nativeName: 'پښتو',
      englishName: 'Pashto',
    ),
    OnboardingLanguage(
      code: 'SD',
      nativeName: 'سنڌي',
      englishName: 'Sindhi',
    ),
    OnboardingLanguage(
      code: 'AR',
      nativeName: 'العربية',
      englishName: 'Arabic',
    ),
    OnboardingLanguage(
      code: 'HI',
      nativeName: 'हिन्दी',
      englishName: 'Hindi',
    ),
  ];

  static const List<OnboardingCurrency> currencies = [
    OnboardingCurrency(code: 'PKR', name: 'Pakistani Rupee', symbol: 'Rs'),
    OnboardingCurrency(code: 'USD', name: 'US Dollar', symbol: '\u0024'),
    OnboardingCurrency(code: 'AED', name: 'UAE Dirham', symbol: 'AED'),
    OnboardingCurrency(code: 'SAR', name: 'Saudi Riyal', symbol: 'SR'),
    OnboardingCurrency(code: 'GBP', name: 'British Pound', symbol: '\u00A3'),
    OnboardingCurrency(code: 'EUR', name: 'Euro', symbol: '\u20AC'),
    OnboardingCurrency(code: 'INR', name: 'Indian Rupee', symbol: '\u20B9'),
    OnboardingCurrency(code: 'CAD', name: 'Canadian Dollar', symbol: 'C\u0024'),
    OnboardingCurrency(code: 'AUD', name: 'Australian Dollar',
        symbol: 'A\u0024'),
    OnboardingCurrency(code: 'TRY', name: 'Turkish Lira', symbol: '\u20BA'),
  ];

  Box get _box => Hive.box(AppKeys.settingsBox);

  /// True once the user has been through onboarding on this install.
  static bool get hasSeen {
    if (!Hive.isBoxOpen(AppKeys.settingsBox)) return true;
    return Hive.box(AppKeys.settingsBox)
        .get(seenKey, defaultValue: false) as bool;
  }

  @override
  void onInit() {
    super.onInit();

    // Carry over whatever is already set, so going back through
    // onboarding does not silently reset the user's currency.
    if (Hive.isBoxOpen(AppKeys.settingsBox)) {
      selectedCurrency.value =
          _box.get('currency', defaultValue: 'PKR') as String;
      selectedLanguage.value =
          _box.get(languageKey, defaultValue: 'en') as String;
    }
  }

  bool get isLastPage => pageIndex.value == pageCount - 1;

  void setLanguage(String code) => selectedLanguage.value = code;

  void setCurrency(String code) => selectedCurrency.value = code;

  void next() {
    if (pageIndex.value < pageCount - 1) pageIndex.value++;
  }

  void back() {
    if (pageIndex.value > 0) pageIndex.value--;
  }

  /// Saves both choices and marks onboarding done.
  Future<void> finish() async {
    if (Hive.isBoxOpen(AppKeys.settingsBox)) {
      await _box.put(languageKey, selectedLanguage.value);
      await _box.put(seenKey, true);
    }

    // Push the currency through the settings controller so every screen
    // picks it up straight away, instead of only after a restart.
    final settings = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : Get.put(SettingsController());

    await settings.changeCurrency(selectedCurrency.value);
  }
}
