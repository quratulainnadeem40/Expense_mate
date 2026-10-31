import 'package:expense_mate/Core/localization/app_translations.dart';
import 'package:expense_mate/Feature/onboarding/controller/onboarding_controller.dart';
import 'package:expense_mate/Feature/goals/model/goal_icon.dart';
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

  test(
    'category records use reviewed Urdu terms without changing custom text',
    () {
      expect(
        AppTranslations.localizeCategoryRecord('food', languageCode: 'ur'),
        'کھانا',
      );
      expect(
        AppTranslations.localizeCategoryRecord('Education', languageCode: 'ur'),
        'تعلیم',
      );
      expect(
        AppTranslations.localizeCategoryRecord(
          'Custom market 24',
          languageCode: 'ur',
        ),
        'Custom market 24',
      );
      expect(
        AppTranslations.localizeCategoryRecord('food', languageCode: 'en'),
        'food',
      );
    },
  );

  test('Urdu covers the complete budget screen and budget history', () {
    final urdu = AppTranslations().keys['ur']!;

    for (final key in [
      'Live Budget',
      'Budget Cycle',
      'Select Month Start',
      'Updates on its own every month',
      'Reset Reminder',
      'Remind me',
      '1 day before',
      '@count days before',
      'Budget resets on its own each cycle.',
      'Budget will not reset automatically.',
      'Last Reset',
      'Next Reset',
      'Reset Budget Now',
      'Change Budget Start Date?',
      'Set Limit for @category',
      'Set Total Monthly Budget',
      'Edit limit',
      'Add Custom Category',
      'Budget cycle settings',
      'Budget history',
      'Clear history',
      'Budget Exceeded',
      'Category Budgets',
      'Add category budget',
      'Budget History',
      'Saved across all cycles',
      'Overspent across all cycles',
      'Automatic reset',
      'Manual reset',
      'Saved',
      'Over by',
      'Limit',
      'Spent',
      'Hide categories',
      'Show @count categories',
      'No history yet',
    ]) {
      expect(urdu[key], isNotNull, reason: 'Missing Urdu translation: $key');
      expect(urdu[key], isNot(key), reason: 'Untranslated Urdu label: $key');
    }

    expect(
      AppTranslations.localizeCategoryRecord('Gym', languageCode: 'ur'),
      'جم',
    );
  });

  test('Urdu covers the profile, account actions, and About screen', () {
    final translations = AppTranslations().keys;
    final urdu = translations['ur']!;
    final english = translations['en']!;

    for (final key in [
      'Profile',
      'Appearance',
      'Dark Mode',
      'Dark theme is enabled',
      'Light theme is enabled',
      'Currency',
      'Default Currency',
      'Language',
      'Hide amounts',
      'Balances are hidden on the home screen',
      'Balances are visible on the home screen',
      'Notifications',
      'Bill Notifications',
      'Receive reminders for upcoming bills',
      'Change app PIN',
      'Set an app PIN',
      'Asked for each time the app opens',
      'Lock the app with four digits',
      'Unlock with fingerprint',
      'Your PIN still works if it fails',
      'Remove app PIN',
      'The app will open without asking',
      'Transaction Sound',
      'Play a short tone when an entry is saved',
      'Account',
      'Sign out from your ExpenseMate account',
      'Logout',
      'Delete Account',
      'Permanently delete your account and data',
      'ExpenseMate Account',
      'Entries',
      'Wallets',
      'Goals',
      'Edit profile',
      'Update your account details',
      'ACCOUNT DETAILS',
      'Name',
      'Email',
      'New Password',
      'Leave empty to keep current password',
      'Leave password empty if you do not want to change it.',
      'Change',
      'Clear',
      'Save changes',
      'Please enter your name.',
      'Password must be at least 6 characters.',
      'No logged-in account found.',
      'Profile Updated',
      'Name and email updated successfully.',
      'Name updated successfully.',
      'Email updated successfully.',
      'Password updated successfully.',
      'Confirmation Required',
      'A confirmation email has been sent to your new email address. Please confirm it before the email change becomes active.',
      'Profile database update failed.',
      'Unable to update profile. Please try again.',
      'Unable to update name.',
      'Profile Picture Removed',
      'Your profile picture has been cleared.',
      'Unable to update profile picture.',
      'Unable to clear profile picture.',
      'Logout?',
      'Are you sure you want to logout from your ExpenseMate account?',
      'You have been logged out successfully.',
      'Unable to logout. Please try again.',
      'Delete Account?',
      'This action is permanent. Your ExpenseMate account and associated account data will be deleted. You will not be able to recover your account.',
      'This cannot be undone.',
      'Your ExpenseMate account has been permanently deleted.',
      'Unable to delete account. Please try again.',
      'About',
      'Expense management made simple',
      'Version 1.0.0',
      'What is Expense Mate?',
      'What each screen does',
      'Your data',
      'Your transactions are tied to your account and synced securely to the cloud, so you keep your history even if you change your phone. Only you can see your data — it is never sold or shared with advertisers.',
      'Password protected account',
      'Automatic cloud backup',
      'No ads, no data selling',
      'App information',
      'Version',
      'Developer',
      'Package',
      'Support & legal',
      'Contact support',
      'Website',
      'Privacy policy',
      'Terms of service',
      'Made with Flutter',
      'Version @version',
    ]) {
      expect(urdu[key], isNotNull, reason: 'Missing Urdu translation: $key');
      expect(urdu[key], isNot(key), reason: 'Untranslated Urdu label: $key');
    }

    expect(english['Account'], 'Account');
    expect(urdu['Version @version'], contains('@version'));
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
      '@count selected',
      'Total: @amount',
      '1 Transaction',
      'Transactions: @count',
      'No transactions found for this category in the selected period.',
      'Category Type',
      'Select Icon',
      'Add New Category',
      'Enter category name',
      'Please enter category name.',
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

  test('Urdu covers drawer screens and nested budget, goal, and bill UI', () {
    final urdu = AppTranslations().keys['ur']!;

    for (final key in [
      'Monthly budget exceeded',
      'Edit Monthly Limit',
      'Change Budget Start Date?',
      'Category Name',
      'Monthly Limit',
      'Total Limit',
      'Custom category added.',
      'Delete Category',
      'Budget Exceeded',
      'Reset Budget Now',
      'In progress',
      'Pick an icon',
      'Goal name',
      'Target amount',
      'Target date',
      'Already saved (optional)',
      'Choose a date',
      '3 months',
      '6 months',
      '1 year',
      'Withdraw money',
      'Add to goal',
      'Goal created',
      'Goal updated',
      'Goal deleted',
      'Create goal',
      'Bill added successfully.',
      'Bill updated successfully.',
      'Bill deleted successfully.',
      'Unable to load bills. Please try again.',
      'Monthly',
      'Reminders & Notifications',
    ]) {
      expect(urdu[key], isNotNull, reason: 'Missing Urdu translation: $key');
      expect(urdu[key], isNot(key), reason: 'Untranslated Urdu label: $key');
    }

    expect(urdu['@title — @currency @amount still needed'], contains('@title'));
    expect(
      urdu['This category would push your total monthly budget from @current to @projected.\n\nYou are over by @amount.'],
      contains('@projected'),
    );
  });

  test('Urdu translates every goal icon label', () {
    final urdu = AppTranslations().keys['ur']!;

    for (final option in goalIconOptions) {
      expect(
        urdu[option.label],
        isNotNull,
        reason: 'Missing Urdu goal icon label: ${option.label}',
      );
      expect(
        urdu[option.label],
        isNot(option.label),
        reason: 'Untranslated Urdu goal icon label: ${option.label}',
      );
    }
  });

  test('Urdu covers the drawer strings visible in the screenshots', () {
    final urdu = AppTranslations().keys['ur']!;

    for (final key in [
      'Live Budget',
      'Total Monthly Budget Spent',
      '@cycle · @count days left',
      'Category Budgets',
      'Spent: @spent / @allocated',
      'Over by @amount',
      'No upcoming bills',
      'No paid bills yet',
      'e.g. @icon goal',
      '3 months',
      '6 months',
      '1 year',
      '@amount lakh',
      '@amount thousand',
      'Create goal',
      'Set an app PIN',
      'Lock the app with four digits',
      'Transaction Sound',
      'Play a short tone when an entry is saved',
      'About',
      'What is Expense Mate?',
      'What each screen does',
      'Your data',
      'App information',
      'Support & legal',
      'Profile & Settings',
    ]) {
      expect(urdu[key], isNotNull, reason: 'Missing Urdu translation: $key');
      expect(urdu[key], isNot(key), reason: 'Untranslated Urdu label: $key');
    }

    expect(urdu['@cycle · @count days left'], contains('@count'));
    expect(urdu['@cycle · @count days left'], contains('@cycle'));
    expect(urdu['@amount lakh'], contains('@amount'));
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
