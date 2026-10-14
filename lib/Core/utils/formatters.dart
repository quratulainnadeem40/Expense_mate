import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Feature/settings/controller/settings_controller.dart';

class Formatters {
  /// The currency the user picked in Settings.
  ///
  /// Falls back to PKR when the settings controller is not registered
  /// yet, which can happen on the very first frame.
  static String get code {
    if (!Get.isRegistered<SettingsController>()) return 'PKR';
    return Get.find<SettingsController>().selectedCurrency.value;
  }

  /// An amount with the current currency in front, e.g. "PKR 1,200".
  ///
  /// Reading it inside an Obx makes the text change the moment the user
  /// switches currency, because selectedCurrency is observable.
  static String money(num amount, {int decimals = 0}) {
    final pattern = decimals > 0 ? '#,##0.${'0' * decimals}' : '#,##0';
    final number = NumberFormat(pattern, 'en_US').format(amount);

    return '$code $number';
  }

  /// Same as money() but with a leading + or -, for transaction rows.
  static String signedMoney(
    num amount, {
    required bool isIncome,
    int decimals = 0,
  }) {
    return '${isIncome ? '+' : '-'}${money(amount, decimals: decimals)}';
  }

  /// Kept for older call sites. Now honours the chosen currency instead
  /// of always printing a dollar sign.
  static String formatCurrency(double amount) => money(amount, decimals: 2);

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
