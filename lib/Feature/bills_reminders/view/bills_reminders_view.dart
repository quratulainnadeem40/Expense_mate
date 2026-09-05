import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../settings/controller/settings_controller.dart';
import '../../../Core/theme/custom_colors.dart';
import '../controller/bills_reminders_controller.dart';
import '../model/bill_model.dart';
import 'add_bill_view.dart';
import 'edit_bill_view.dart';

class BillsRemindersView extends GetView<BillsRemindersController> {
  const BillsRemindersView({super.key});
  SettingsController get settingsController =>
      Get.find<SettingsController>();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bills & Reminders',
          style: AppTextStyles.headingMedium(isDark),
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.loadBills();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              // ====================================================
              // SUMMARY
              // ====================================================

              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Upcoming',
                      count: controller.upcomingCount,
                      currency: settingsController.selectedCurrency.value,
                      amount: controller.upcomingAmount,
                      icon: Icons.event_note_rounded,
                      isDark: isDark,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _SummaryCard(
                      title: 'Overdue',
                      count: controller.overdueCount,
                      currency: settingsController.selectedCurrency.value,
                      amount: controller.overdueAmount,
                      icon: Icons.warning_amber_rounded,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _SummaryCard(
                title: 'Paid',
                count: controller.paidCount,
                currency: settingsController.selectedCurrency.value,
                amount: controller.paidAmount,
                icon: Icons.check_circle_outline_rounded,
                isDark: isDark,
                fullWidth: true,
              ),

              const SizedBox(height: 28),
 // ====================================================
//DUE TODAY
// ====================================================

_SectionTitle(
  title: 'Due Today',
  count: controller.todayBills.length,
  isDark: isDark,
),

const SizedBox(height: 12),

if (controller.todayBills.isEmpty)
  _EmptySection(
    message: 'No bills due today',
    icon: Icons.today_outlined,
    isDark: isDark,
  )
else
  ...controller.todayBills.map(
    (bill) => _BillTile(
      bill: bill,
      isDark: isDark,
      currency: settingsController.selectedCurrency.value,
      onMarkPaid: () {
        controller.markAsPaid(bill.id);
      },
      onDelete: () {
        _showDeleteDialog(
          context,
          bill.name,
          bill.id,
        );
      },
      onEdit: () {
        Get.to(
          () => EditBillView(bill: bill),
        );
      },
    ),
  ),

// ====================================================
// UPCOMING BILLS
// ====================================================

const SizedBox(height: 24),

_SectionTitle(
  title: 'Upcoming Bills',
  count: controller.upcomingBills.length,
  isDark: isDark,
),

const SizedBox(height: 12),

if (controller.upcomingBills.isEmpty)
  _EmptySection(
    message: 'No upcoming bills',
    icon: Icons.event_available_rounded,
    isDark: isDark,
  )
else
  ...controller.upcomingBills.map(
    (bill) => _BillTile(
      bill: bill,
      isDark: isDark,
      currency: settingsController.selectedCurrency.value,
      onMarkPaid: () {
        controller.markAsPaid(bill.id);
      },
      onDelete: () {
        _showDeleteDialog(
          context,
          bill.name,
          bill.id,
        );
      },
      onEdit: () {
        Get.to(
          () => EditBillView(bill: bill),
        );
      },
    ),
  ),

              // ====================================================
              // OVERDUE BILLS
              // ====================================================

              const SizedBox(height: 24),

              _SectionTitle(
                title: 'Overdue Bills',
                count: controller.overdueBills.length,
                isDark: isDark,
              ),

              const SizedBox(height: 12),

              if (controller.overdueBills.isEmpty)
                _EmptySection(
                  message: 'No overdue bills',
                  icon: Icons.check_circle_outline_rounded,
                  isDark: isDark,
                )
              else
                ...controller.overdueBills.map(
                  (bill) => _BillTile(
                    bill: bill,
                    isDark: isDark,
                    isOverdue: true,
                    currency: settingsController.selectedCurrency.value,

                    onMarkPaid: () {
                      controller.markAsPaid(bill.id);
                    },

                    onDelete: () {
                      _showDeleteDialog(
                        context,
                        bill.name,
                        bill.id,
                      );
                    },

                    onEdit: () {
                      Get.to(
                        () => EditBillView(bill: bill),
                      );
                    },
                  ),
                ),

              // ====================================================
              // PAID BILLS
              // ====================================================

              const SizedBox(height: 24),

              _SectionTitle(
                title: 'Paid Bills',
                count: controller.paidBills.length,
                isDark: isDark,
              ),

              const SizedBox(height: 12),

              if (controller.paidBills.isEmpty)
                _EmptySection(
                  message: 'No paid bills yet',
                  icon: Icons.receipt_long_outlined,
                  isDark: isDark,
                )
              else
                ...controller.paidBills.map(
                  (bill) => _BillTile(
                    bill: bill,
                    isDark: isDark,
                      currency: settingsController.selectedCurrency.value,

                    onMarkPaid: () {
                      controller.markAsUnpaid(bill.id);
                    },

                    onDelete: () {
                      _showDeleteDialog(
                        context,
                        bill.name,
                        bill.id,
                      );
                    },

                    onEdit: () {
                      Get.to(
                        () => EditBillView(bill: bill),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 80),
            ],
          ),
        );
      }),

      // ==========================================================
      // ADD BILL BUTTON
      // ==========================================================

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(
            () => const AddBillView(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Bill'),
      ),
    );
  }

  // ============================================================
  // DELETE DIALOG
  // ============================================================

  void _showDeleteDialog(
    BuildContext context,
    String billName,
    String billId,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Bill'),

        content: Text(
          'Are you sure you want to delete "$billName"?',
        ),

        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Cancel'),
          ),

          TextButton(
            onPressed: () {
              controller.deleteBill(billId);
              Get.back();
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppColors.expenseRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SUMMARY CARD
// ============================================================

class _SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final double amount;
  final String currency;
  final IconData icon;
  final bool isDark;
  final bool fullWidth;

  const _SummaryCard({
    required this.title,
    required this.count,
    required this.amount,
    required this.currency,
    required this.icon,
    required this.isDark,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        children: [
          // ======================================================
          // ICON
          // ======================================================

          Container(
            width: 44,
            height: 44,

            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 12),

          // ======================================================
          // DETAILS
          // ======================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium(isDark),
                ),

                const SizedBox(height: 3),

                Text(
                  '$count bill${count == 1 ? '' : 's'}',
                  style: AppTextStyles.bodyLarge(isDark).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

               Text(
  '$currency ${amount.toStringAsFixed(2)}',
  style: AppTextStyles.caption(isDark),
),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

class _SectionTitle extends StatelessWidget {
  final String title;
  final int count;
  final bool isDark;

  const _SectionTitle({
    required this.title,
    required this.count,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.headingMedium(isDark),
        ),

        Text(
          '$count',
          style: AppTextStyles.bodyMedium(isDark).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// BILL TILE
// ============================================================

class _BillTile extends StatelessWidget {
 final BillModel bill;
final bool isDark;
final bool isOverdue;
final String currency;

  final VoidCallback onMarkPaid;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _BillTile({
    required this.bill,
    required this.isDark,
    required this.currency,
    required this.onMarkPaid,
    required this.onDelete,
    required this.onEdit,
    this.isOverdue = false,
  });

  @override
  Widget build(BuildContext context) {
    final date =
        '${bill.dueDate.day.toString().padLeft(2, '0')}/'
        '${bill.dueDate.month.toString().padLeft(2, '0')}/'
        '${bill.dueDate.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,

      color: isDark
          ? AppColors.surfaceDark
          : AppColors.surfaceLight,

      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),

        // ========================================================
        // LEADING ICON
        // ========================================================

        leading: CircleAvatar(
          backgroundColor: isOverdue
              ? AppColors.expenseRed.withValues(alpha: 0.10)
              : AppColors.primary.withValues(alpha: 0.10),

          child: Icon(
            isOverdue
                ? Icons.warning_amber_rounded
                : Icons.receipt_long_rounded,

            color: isOverdue
                ? AppColors.expenseRed
                : AppColors.primary,
          ),
        ),

        // ========================================================
        // BILL NAME
        // ========================================================

        title: Text(
          bill.name,
          style: AppTextStyles.bodyLarge(isDark).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        // ========================================================
        // BILL DETAILS
        // ========================================================

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

            Text(
              '${bill.category} • ${bill.repeat}',
              style: AppTextStyles.bodyMedium(isDark),
            ),

            const SizedBox(height: 3),

            Text(
              'Due: $date',
              style: AppTextStyles.caption(isDark),),
               SizedBox(height: 3),

            const SizedBox(height: 3),

            Text(
              '$currency ${bill.amount.toStringAsFixed(2)}',
              style: AppTextStyles.caption(isDark).copyWith(
                fontWeight: FontWeight.w600,
  ),
),
            
          ],
        ),

        // ========================================================
        // MENU
        // ========================================================

        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'paid') {
              onMarkPaid();
            } else if (value == 'delete') {
              onDelete();
            }
          },

          itemBuilder: (context) {
            return [
              // ==================================================
              // EDIT
              // ==================================================

              const PopupMenuItem<String>(
                value: 'edit',

                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 20,
                    ),

                    SizedBox(width: 10),

                    Text('Edit'),
                  ],
                ),
              ),

              // ==================================================
              // MARK PAID / UNPAID
              // ==================================================

              PopupMenuItem<String>(
                value: 'paid',

                child: Row(
                  children: [
                    Icon(
                      bill.isPaid
                          ? Icons.undo_rounded
                          : Icons.check_circle_outline,
                    ),

                    const SizedBox(width: 8),

                    Text(
                      bill.isPaid
                          ? 'Mark Unpaid'
                          : 'Mark Paid',
                    ),
                  ],
                ),
              ),

              // ==================================================
              // DELETE
              // ==================================================

              const PopupMenuItem<String>(
                value: 'delete',

                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color: AppColors.expenseRed,
                    ),

                    SizedBox(width: 8),

                    Text('Delete'),
                  ],
                ),
              ),
            ];
          },
        ),

        isThreeLine: true,
      ),
    );
  }
}

// ============================================================
// EMPTY SECTION
// ============================================================

class _EmptySection extends StatelessWidget {
  final String message;
  final IconData icon;
  final bool isDark;

  const _EmptySection({
    required this.message,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(
        vertical: 28,
        horizontal: 16,
      ),

      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        children: [
          Icon(
            icon,
            size: 42,
            color: AppColors.primary,
          ),

          const SizedBox(height: 10),

          Text(
            message,
            style: AppTextStyles.bodyMedium(isDark),
          ),
        ],
      ),
    );
  }
}