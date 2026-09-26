class AppKeys {
  static const String transactionsBox = 'transactions_box';
  static const String categoriesBox = 'categories_box';

  static const String walletsBox = 'wallets_box';
  static const String billsRemindersBox = 'bills_reminders_box';

  static const String settingsBox = 'settings_box';
  static const String budgetBox = 'budget_box';

  static const String isDarkModeKey = 'is_dark_mode';
  static const String monthlyBudgetKey = 'monthly_budget_limit';
  static const String categoryBudgetKey = 'category_budget_limits';

  // Budget cycle settings. These used to be local variables inside
  // the bottom sheet, so they were lost every time it closed.
  static const String budgetMonthStartDayKey = 'budget_month_start_day';
  static const String budgetResetModeKey = 'budget_reset_is_automatic';
  static const String budgetLastResetKey = 'budget_last_reset_date';
  static const String budgetHistoryKey = 'budget_cycle_history';
}