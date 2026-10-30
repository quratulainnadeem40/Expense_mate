import 'package:expense_mate/Core/localization/app_translations.dart';
import 'package:expense_mate/Feature/onboarding/controller/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('onboarding offers only Urdu and English', () {
    expect(OnboardingController.languages.map((language) => language.code), [
      'UR',
      'EN',
    ]);
  });

  const requiredKeys = [
    'Choose your language',
    'Home',
    'Transactions',
    'Categories',
    'Reports',
    'Settings',
    'Welcome Back!',
    'Email',
    'Password',
    'Login',
    'Sign Up',
  ];

  test('provides every supported locale and core UI translation', () {
    final translations = AppTranslations().keys;

    expect(translations.keys, containsAll(AppTranslations.languageCodes));
    for (final languageCode in AppTranslations.languageCodes) {
      expect(translations[languageCode]!.keys, containsAll(requiredKeys));
    }
  });

  test('core navigation labels are translated for supported languages', () {
    final translations = AppTranslations().keys;

    for (final languageCode in AppTranslations.languageCodes.skip(1)) {
      expect(translations[languageCode]!['Home'], isNot('Home'));
      expect(
        translations[languageCode]!['Transactions'],
        isNot('Transactions'),
      );
    }
  });

  test('Urdu covers the Home and Categories labels shown in the app', () {
    final urdu = AppTranslations().keys['ur']!;

    for (final key in [
      'Hello',
      'Welcome back to Expense Mate',
      'Total Balance',
      'Recent Transactions',
      'View All',
      'No recent transactions found.',
      'Categories',
      'Select',
      'No categories found',
      'Set Up Your Category Cycle',
      'Cycle Start Day',
      'Category Reset Mode',
      'Education',
      'Food',
      'Bills',
      'Transport',
      'Health',
    ]) {
      expect(urdu[key], isNotNull, reason: 'Missing Urdu translation: $key');
      expect(urdu[key], isNot(key), reason: 'Untranslated Urdu label: $key');
    }

    expect(
      urdu['Category totals roll over automatically on day @day each month. Your transactions remain saved.'],
      contains('@day'),
    );
  });

  test('Urdu translates committee schedule labels and dynamic messages', () {
    final urdu = AppTranslations().keys['ur']!;

    for (final key in [
      'Committee Schedule',
      'Committee Allocated',
      'Allocated Rounds',
      'Allocating...',
      'Spinning...',
      'Already allocated',
      'Allocate by added order',
      'All members allocated',
      'Spin & allocate',
      'Spin & allocate a recipient for @month.',
      'No recipients have been allocated yet. Use Spin & allocate to choose the first recipient.',
      'Upcoming',
    ]) {
      expect(urdu[key], isNotNull, reason: 'Missing Urdu translation: $key');
      expect(urdu[key], isNot(key), reason: 'Untranslated Urdu label: $key');
    }

    expect(
      urdu['@name is set to receive the committee for @month.'],
      contains('@month'),
    );
    expect(
      urdu['@name is allocated to receive the committee for @month.'],
      contains('@name'),
    );
  });

  test('Urdu translates onboarding copy and currency names', () {
    final urdu = AppTranslations().keys['ur']!;

    for (final key in [
      'Choose your language',
      'You can change it later in Settings.',
      'Your money, on your phone',
      'Every entry is stored on this device first and synced to your account, so the app keeps working even when the signal does not.',
      'An entry takes three taps',
      'Tap the green button, type the amount, pick a category and wallet. Budgets, goals and reports fill themselves in from there.',
      'Choose your currency',
      'Every amount in the app is shown in this currency.',
      'Pakistani Rupee',
      'US Dollar',
      'UAE Dirham',
      'Saudi Riyal',
      'British Pound',
      'Euro',
      'Indian Rupee',
      'Canadian Dollar',
      'Australian Dollar',
      'Turkish Lira',
      'Next',
      'Get started',
    ]) {
      expect(urdu[key], isNotNull, reason: 'Missing Urdu translation: $key');
      expect(urdu[key], isNot(key), reason: 'Untranslated Urdu label: $key');
    }
  });

  test('Urdu translates category and wallet picker values', () {
    final urdu = AppTranslations().keys['ur']!;

    for (final key in [
      'Education',
      'Food',
      'Bills',
      'Transport',
      'Health',
      'Salary',
      'Freelance',
      'Business',
      'Gift',
      'Profit',
      'Cash',
      'Bank',
      'Bank Account',
      'JazzCash',
      'Jazzcash',
      'Easypaisa',
      'Credit Card',
      'Other',
      'More...',
    ]) {
      expect(urdu[key], isNotNull, reason: 'Missing Urdu translation: $key');
      expect(urdu[key], isNot(key), reason: 'Untranslated Urdu label: $key');
    }
  });

  testWidgets(
    'text fields have framework localizations for Pashto and Sindhi',
    (tester) async {
      for (final languageCode in ['ps', 'sd']) {
        await tester.pumpWidget(
          GetMaterialApp(
            locale: Locale(languageCode),
            fallbackLocale: const Locale('en'),
            translations: AppTranslations(),
            supportedLocales: AppTranslations.languageCodes
                .map(Locale.new)
                .toList(),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: AppTranslations.resolveFrameworkLocale,
            home: const Scaffold(body: TextField()),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(
          Localizations.localeOf(
            tester.element(find.byType(TextField)),
          ).languageCode,
          'en',
        );
      }
    },
  );
}
