import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../Core/constants/app_keys.dart';
import '../../../Core/service/notification_service.dart';
import '../../settings/controller/settings_controller.dart';
import '../model/bill_model.dart';

class BillsRemindersController extends GetxController {
  late Box billsBox;

  final bills = <BillModel>[].obs;
  final isLoading = false.obs;

  // ==========================================================
  // CONTROLLERS / SERVICES
  // ==========================================================

  final NotificationService notificationService =
      Get.find<NotificationService>();

  SettingsController get settingsController =>
      Get.find<SettingsController>();

  // ==========================================================
  // FILTERED BILLS
  // ==========================================================

  List<BillModel> get upcomingBills {
    final now = DateTime.now();

    return bills.where((bill) {
      return !bill.isPaid &&
          !isSameDay(bill.dueDate, now) &&
          bill.dueDate.isAfter(
            DateTime(now.year, now.month, now.day),
          );
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  List<BillModel> get paidBills {
    return bills.where((bill) => bill.isPaid).toList()
      ..sort((a, b) => b.dueDate.compareTo(a.dueDate));
  }

  List<BillModel> get overdueBills {
    final now = DateTime.now();

    return bills.where((bill) {
      return !bill.isPaid &&
          bill.dueDate.isBefore(
            DateTime(now.year, now.month, now.day),
          );
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  List<BillModel> get todayBills {
    final now = DateTime.now();

    return bills.where((bill) {
      return !bill.isPaid && isSameDay(bill.dueDate, now);
    }).toList();
  }

  // ==========================================================
  // COUNTS
  // ==========================================================

  int get upcomingCount => upcomingBills.length;

  int get paidCount => paidBills.length;

  int get overdueCount => overdueBills.length;

  // ==========================================================
  // TOTAL AMOUNTS
  // ==========================================================

  double get upcomingAmount {
    return upcomingBills.fold(
      0.0,
      (sum, bill) => sum + bill.amount,
    );
  }

  double get overdueAmount {
    return overdueBills.fold(
      0.0,
      (sum, bill) => sum + bill.amount,
    );
  }

  double get paidAmount {
    return paidBills.fold(
      0.0,
      (sum, bill) => sum + bill.amount,
    );
  }

  // ==========================================================
  // INITIALIZATION
  // ==========================================================

  @override
  void onInit() {
    super.onInit();

    billsBox = Hive.box(
      AppKeys.billsRemindersBox,
    );

    loadBills();
  }

  // ==========================================================
  // LOAD BILLS
  // ==========================================================

  Future<void> loadBills() async {
    isLoading.value = true;

    final loadedBills = billsBox.values.map((item) {
      return BillModel.fromMap(
        Map<dynamic, dynamic>.from(item),
      );
    }).toList();

    bills.assignAll(loadedBills);

    isLoading.value = false;

    // Schedule notifications for existing unpaid bills.
    await _scheduleAllBillNotifications();
  }

  // ==========================================================
  // SCHEDULE ALL BILL NOTIFICATIONS
  // ==========================================================

  Future<void> _scheduleAllBillNotifications() async {
    if (!settingsController.notificationsEnabled.value) {
      return;
    }

    for (final bill in bills) {
      if (!bill.isPaid) {
        await _scheduleBillNotification(bill);
      }
    }
  }

  // ==========================================================
  // SCHEDULE SINGLE BILL NOTIFICATION
  // ==========================================================

  Future<void> _scheduleBillNotification(
    BillModel bill,
  ) async {
    if (bill.isPaid) return;

    if (!settingsController.notificationsEnabled.value) {
      return;
    }

    await notificationService.scheduleBillNotification(
      notificationId: _notificationId(bill.id),
      billName: bill.name,
      amount: bill.amount,
      currency: settingsController.selectedCurrency.value,
      dueDate: bill.dueDate,
    );
  }

  // ==========================================================
  // NOTIFICATION ID
  // ==========================================================

  int _notificationId(String billId) {
    return billId.hashCode.abs();
  }

  // ==========================================================
  // ADD BILL
  // ==========================================================

  Future<void> addBill({
    required String name,
    required double amount,
    required DateTime dueDate,
    required String category,
    required String repeat,
  }) async {
    final id = DateTime.now()
        .millisecondsSinceEpoch
        .toString();

    final bill = BillModel(
      id: id,
      name: name,
      amount: amount,
      dueDate: dueDate,
      category: category,
      repeat: repeat,
      isPaid: false,
    );

    await billsBox.put(
      id,
      bill.toMap(),
    );

    bills.add(bill);
    bills.refresh();

    // Schedule notification for the new bill.
    await _scheduleBillNotification(bill);
  }

  // ==========================================================
  // UPDATE BILL
  // ==========================================================

  Future<void> updateBill(BillModel bill) async {
    // Cancel the old notification first.
    await notificationService.cancelNotification(
      _notificationId(bill.id),
    );

    await billsBox.put(
      bill.id,
      bill.toMap(),
    );

    final index = bills.indexWhere(
      (item) => item.id == bill.id,
    );

    if (index != -1) {
      bills[index] = bill;
      bills.refresh();
    }

    // Schedule the updated bill if it is unpaid.
    await _scheduleBillNotification(bill);
  }

  // ==========================================================
  // MARK AS PAID
  // ==========================================================

  Future<void> markAsPaid(String billId) async {
    final index = bills.indexWhere(
      (bill) => bill.id == billId,
    );

    if (index == -1) return;

    final bill = bills[index];

    // Cancel notification when bill is paid.
    await notificationService.cancelNotification(
      _notificationId(bill.id),
    );

    final updatedBill = bill.copyWith(
      isPaid: true,
    );

    await updateBill(updatedBill);
  }

  // ==========================================================
  // MARK AS UNPAID
  // ==========================================================

  Future<void> markAsUnpaid(String billId) async {
    final index = bills.indexWhere(
      (bill) => bill.id == billId,
    );

    if (index == -1) return;

    final bill = bills[index];

    final updatedBill = bill.copyWith(
      isPaid: false,
    );

    await updateBill(updatedBill);
  }

  // ==========================================================
  // DELETE BILL
  // ==========================================================

  Future<void> deleteBill(String billId) async {
    // Cancel notification before deleting the bill.
    await notificationService.cancelNotification(
      _notificationId(billId),
    );

    await billsBox.delete(billId);

    bills.removeWhere(
      (bill) => bill.id == billId,
    );

    bills.refresh();
  }

  // ==========================================================
  // CLEAR ALL BILLS
  // ==========================================================

  Future<void> clearBills() async {
    await billsBox.clear();

    bills.clear();

    // Remove all scheduled notifications.
    await notificationService.cancelAllNotifications();
  }

  // ==========================================================
  // DATE HELPER
  // ==========================================================

  bool isSameDay(
    DateTime first,
    DateTime second,
  ) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}