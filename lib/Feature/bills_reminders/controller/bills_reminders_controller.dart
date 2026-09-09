import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../Core/service/notification_service.dart';
import '../../settings/controller/settings_controller.dart';
import '../model/bill_model.dart';

class BillsRemindersController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final bills = <BillModel>[].obs;
  final isLoading = false.obs;

  final NotificationService notificationService =
      Get.find<NotificationService>();

  SettingsController get settingsController =>
      Get.find<SettingsController>();

  User? get currentUser => _supabase.auth.currentUser;

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
    loadBills();
  }

  // ==========================================================
  // LOAD BILLS
  // ==========================================================

  Future<void> loadBills() async {
    final user = currentUser;

    if (user == null) {
      bills.clear();
      return;
    }

    try {
      isLoading.value = true;

      final response = await _supabase
          .from('bills_reminders')
          .select()
          .eq('user_id', user.id)
          .order('due_date', ascending: true);

      bills.assignAll(
        (response as List)
            .map(
              (item) => BillModel.fromMap(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(),
      );
    } on PostgrestException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError(
        'Unable to load bills. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }

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
      if (!bill.isPaid && bill.reminderEnabled) {
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
    if (bill.isPaid || !bill.reminderEnabled) {
      return;
    }

    if (!settingsController.notificationsEnabled.value) {
      return;
    }

    try {
      await notificationService.scheduleBillNotification(
        notificationId: _notificationId(bill.id),
        billName: bill.title,
        amount: bill.amount,
        currency: settingsController.selectedCurrency.value,
        dueDate: bill.dueDate,
      );
    } catch (e) {
      print(
        'NOTIFICATION SCHEDULE ERROR for ${bill.title}: $e',
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
    required String title,
    required double amount,
    required DateTime dueDate,
    String? categoryId,
    String? walletId,
    String? note,
    bool reminderEnabled = true,
    DateTime? reminderTime,
  }) async {
    final user = currentUser;

    if (user == null) {
      _showError('Please login first.');
      return;
    }

    try {
      isLoading.value = true;

      final response = await _supabase
          .from('bills_reminders')
          .insert({
            'user_id': user.id,
            'title': title.trim(),
            'amount': amount,
            'due_date': dueDate.toIso8601String(),
            'category_id': categoryId,
            'wallet_id': walletId,
            'note': note?.trim(),
            'is_paid': false,
            'reminder_enabled': reminderEnabled,
            'reminder_time': reminderTime?.toIso8601String(),
          })
          .select()
          .single();

      final bill = BillModel.fromMap(
        Map<String, dynamic>.from(response),
      );

      bills.add(bill);

      await _scheduleBillNotification(bill);

      Get.snackbar(
        'Success',
        'Bill added successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on PostgrestException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError(
        'Unable to add bill. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================================
  // UPDATE BILL
  // ==========================================================

  Future<void> updateBill(BillModel bill) async {
    final user = currentUser;

    if (user == null) {
      _showError('Please login first.');
      return;
    }

    try {
      isLoading.value = true;

      await notificationService
          .cancelNotification(
        _notificationId(bill.id),
      );

      final response = await _supabase
          .from('bills_reminders')
          .update({
            'title': bill.title,
            'amount': bill.amount,
            'due_date': bill.dueDate.toIso8601String(),
            'category_id': bill.categoryId,
            'wallet_id': bill.walletId,
            'note': bill.note,
            'is_paid': bill.isPaid,
            'reminder_enabled': bill.reminderEnabled,
            'reminder_time':
                bill.reminderTime?.toIso8601String(),
          })
          .eq('id', bill.id)
          .eq('user_id', user.id)
          .select()
          .single();

      final updatedBill = BillModel.fromMap(
        Map<String, dynamic>.from(response),
      );

      final index = bills.indexWhere(
        (item) => item.id == bill.id,
      );

      if (index != -1) {
        bills[index] = updatedBill;
        bills.refresh();
      }

      await _scheduleBillNotification(updatedBill);

      Get.snackbar(
        'Success',
        'Bill updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on PostgrestException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError(
        'Unable to update bill. Please try again.',
      );
    } finally {
      isLoading.value = false;
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
      _showError('Bill not found.');
      return;
    }

    final bill = bills[index];

    await updateBill(
      bill.copyWith(isPaid: true),
    );
  }

  // ==========================================================
  // MARK AS UNPAID
  // ==========================================================

  Future<void> markAsUnpaid(String billId) async {
    final index = bills.indexWhere(
      (bill) => bill.id == billId,
    );

    if (index == -1) {
      _showError('Bill not found.');
      return;
    }

    final bill = bills[index];

    await updateBill(
      bill.copyWith(isPaid: false),
    );
  }

  // ==========================================================
  // TOGGLE REMINDER
  // ==========================================================

  Future<void> toggleReminder(
    String billId,
    bool enabled,
  ) async {
    final index = bills.indexWhere(
      (bill) => bill.id == billId,
    );

    if (index == -1) {
      _showError('Bill not found.');
      return;
    }

    final bill = bills[index];

    await updateBill(
      bill.copyWith(
        reminderEnabled: enabled,
      ),
    );
  }

  // ==========================================================
  // DELETE BILL
  // ==========================================================

  Future<void> deleteBill(String billId) async {
    final user = currentUser;

    if (user == null) {
      _showError('Please login first.');
      return;
    }

    try {
      isLoading.value = true;

      await _supabase
          .from('bills_reminders')
          .delete()
          .eq('id', billId)
          .eq('user_id', user.id);

      bills.removeWhere(
        (bill) => bill.id == billId,
      );

      try {
        await notificationService.cancelNotification(
          _notificationId(billId),
        );
      } catch (e) {
        print(
          'DELETE NOTIFICATION ERROR: $e',
        );
      }

      Get.snackbar(
        'Success',
        'Bill deleted successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on PostgrestException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError(
        'Unable to delete bill. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================================
  // CLEAR ALL BILLS
  // ==========================================================

  Future<void> clearBills() async {
    final user = currentUser;

    if (user == null) {
      _showError('Please login first.');
      return;
    }

    try {
      isLoading.value = true;

      await _supabase
          .from('bills_reminders')
          .delete()
          .eq('user_id', user.id);

      bills.clear();

      try {
        await notificationService.cancelAllNotifications();
      } catch (e) {
        print(
          'CLEAR NOTIFICATIONS ERROR: $e',
        );
      }

      Get.snackbar(
        'Success',
        'All bills cleared.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on PostgrestException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError(
        'Unable to clear bills. Please try again.',
      );
    } finally {
      isLoading.value = false;
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

  // ==========================================================
  // ERROR
  // ==========================================================

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}