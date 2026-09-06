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
  // AMOUNTS
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
    try {
      isLoading.value = true;

      final loadedBills = billsBox.values.map((item) {
        return BillModel.fromMap(
          Map<dynamic, dynamic>.from(item),
        );
      }).toList();

      bills.assignAll(loadedBills);
    } catch (e) {
      print('LOAD BILLS ERROR: $e');
    } finally {
      isLoading.value = false;
    }

    // Notifications should never prevent bills from loading.
    await _scheduleAllBillNotifications();
  }

  // ==========================================================
  // SCHEDULE ALL NOTIFICATIONS
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
  // SCHEDULE ONE NOTIFICATION
  // ==========================================================

  Future<void> _scheduleBillNotification(
    BillModel bill,
  ) async {
    if (bill.isPaid) return;

    if (!settingsController.notificationsEnabled.value) {
      return;
    }

    try {
      await notificationService.scheduleBillNotification(
        notificationId: _notificationId(bill.id),
        billName: bill.name,
        amount: bill.amount,
        currency: settingsController.selectedCurrency.value,
        dueDate: bill.dueDate,
      );
    } catch (e) {
      print(
        'NOTIFICATION SCHEDULE ERROR for ${bill.name}: $e',
      );
    }
  }

  // ==========================================================
  // NOTIFICATION ID
  // ==========================================================

  int _notificationId(String billId) {
    return int.tryParse(billId) ?? billId.hashCode.abs();
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
    try {
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

      // Save to Hive first.
      await billsBox.put(
        id,
        bill.toMap(),
      );

      // Update UI immediately.
      bills.add(bill);
      bills.refresh();

      // Notification is secondary.
      await _scheduleBillNotification(bill);

      print('BILL ADDED: ${bill.name}');
    } catch (e) {
      print('ADD BILL ERROR: $e');
      rethrow;
    }
  }

  // ==========================================================
  // UPDATE BILL
  // ==========================================================

  Future<void> updateBill(BillModel bill) async {
    try {
      // Update Hive first.
      await billsBox.put(
        bill.id,
        bill.toMap(),
      );

      // Update observable list.
      final index = bills.indexWhere(
        (item) => item.id == bill.id,
      );

      if (index != -1) {
        bills[index] = bill;
        bills.refresh();
      }

      // Notification handling comes after the bill is updated.
      try {
        await notificationService.cancelNotification(
          _notificationId(bill.id),
        );
      } catch (e) {
        print('CANCEL OLD NOTIFICATION ERROR: $e');
      }

      await _scheduleBillNotification(bill);

      print('BILL UPDATED: ${bill.name}');
    } catch (e) {
      print('UPDATE BILL ERROR: $e');
      rethrow;
    }
  }

  // ==========================================================
  // MARK AS PAID
  // ==========================================================

  Future<void> markAsPaid(String billId) async {
    final index = bills.indexWhere(
      (bill) => bill.id == billId,
    );

    if (index == -1) {
      print('MARK PAID: BILL NOT FOUND: $billId');
      return;
    }

    final bill = bills[index];

    final updatedBill = bill.copyWith(
      isPaid: true,
    );

    // updateBill handles Hive + UI + notifications.
    await updateBill(updatedBill);

    print('BILL MARKED PAID: ${bill.name}');
  }

  // ==========================================================
  // MARK AS UNPAID
  // ==========================================================

  Future<void> markAsUnpaid(String billId) async {
    final index = bills.indexWhere(
      (bill) => bill.id == billId,
    );

    if (index == -1) {
      print('MARK UNPAID: BILL NOT FOUND: $billId');
      return;
    }

    final bill = bills[index];

    final updatedBill = bill.copyWith(
      isPaid: false,
    );

    await updateBill(updatedBill);

    print('BILL MARKED UNPAID: ${bill.name}');
  }

  // ==========================================================
  // DELETE BILL
  // ==========================================================

  Future<void> deleteBill(String billId) async {
    try {
      // Delete from Hive first.
      await billsBox.delete(billId);

      // Remove from UI immediately.
      bills.removeWhere(
        (bill) => bill.id == billId,
      );

      bills.refresh();

      // Notification cancellation is secondary.
      try {
        await notificationService.cancelNotification(
          _notificationId(billId),
        );
      } catch (e) {
        print('DELETE NOTIFICATION ERROR: $e');
      }

      print('BILL DELETED: $billId');
    } catch (e) {
      print('DELETE BILL ERROR: $e');
      rethrow;
    }
  }

  // ==========================================================
  // CLEAR ALL BILLS
  // ==========================================================

  Future<void> clearBills() async {
    try {
      await billsBox.clear();

      bills.clear();

      try {
        await notificationService.cancelAllNotifications();
      } catch (e) {
        print('CLEAR NOTIFICATIONS ERROR: $e');
      }

      print('ALL BILLS CLEARED');
    } catch (e) {
      print('CLEAR BILLS ERROR: $e');
      rethrow;
    }
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