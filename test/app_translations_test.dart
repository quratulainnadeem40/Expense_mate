import 'package:expense_mate/Core/localization/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
