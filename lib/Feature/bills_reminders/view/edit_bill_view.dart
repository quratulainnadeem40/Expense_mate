
import 'package:expense_mate/Core/routes/app_routes.dart';
import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/bills_reminders_controller.dart';
import '../model/bill_model.dart';

class EditBillView extends StatefulWidget {
  final BillModel bill;

  const EditBillView({
    super.key,
    required this.bill,
  });

  @override
  State<EditBillView> createState() => _EditBillViewState();
}

class _EditBillViewState extends State<EditBillView> {
  final formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController amountController;
  late TextEditingController noteController;

  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();

    // Load existing bill data
    titleController = TextEditingController(
      text: widget.bill.title,
    );

    amountController = TextEditingController(
      text: widget.bill.amount.toString(),
    );

    noteController = TextEditingController(
      text: widget.bill.note ?? '',
    );

    selectedDate = widget.bill.dueDate;
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate.isBefore(DateTime.now())
          ? DateTime.now()
          : selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // ============================================================
  // UPDATE BILL
  // ============================================================

  Future<void> updateBill() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final amount = double.tryParse(
      amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      return;
    }

    final controller = Get.find<BillsRemindersController>();

    final updatedBill = widget.bill.copyWith(
      title: titleController.text.trim(),
      amount: amount,
      dueDate: selectedDate,
      note: noteController.text.trim().isEmpty
          ? null
          : noteController.text.trim(),
    );

    await controller.updateBill(updatedBill);

Get.offNamed(AppRoutes.billsReminders);
    
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Bill',
          style: AppTextStyles.headingMedium(isDark),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Form(
            key: formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // HEADING
                // ==================================================

                Text(
                  'Bill Details',
                  style: AppTextStyles.headingMedium(isDark),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // BILL TITLE
                // ==================================================

                TextFormField(
                  controller: titleController,

                  textInputAction:
                      TextInputAction.next,

                  decoration: const InputDecoration(
                    labelText: 'Bill Name',
                    hintText: 'e.g. Electricity Bill',
                    prefixIcon: Icon(
                      Icons.receipt_long_outlined,
                    ),
                    border: OutlineInputBorder(),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter bill name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ==================================================
                // AMOUNT
                // ==================================================

                TextFormField(
                  controller: amountController,

                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),

                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    hintText: '0.00',
                    prefixIcon: Icon(
                      Icons.payments_outlined,
                    ),
                    border: OutlineInputBorder(),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter amount';
                    }

                    final amount =
                        double.tryParse(value.trim());

                    if (amount == null) {
                      return 'Please enter a valid amount';
                    }

                    if (amount <= 0) {
                      return 'Amount must be greater than 0';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ==================================================
                // DUE DATE
                // ==================================================

                InkWell(
                  onTap: selectDate,

                  borderRadius:
                      BorderRadius.circular(4),

                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Due Date',
                      prefixIcon: Icon(
                        Icons.calendar_today_outlined,
                      ),
                      border: OutlineInputBorder(),
                    ),

                    child: Text(
                      '${selectedDate.day.toString().padLeft(2, '0')}/'
                      '${selectedDate.month.toString().padLeft(2, '0')}/'
                      '${selectedDate.year}',
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // NOTE
                // ==================================================

                TextFormField(
                  controller: noteController,
                  maxLines: 3,

                  decoration: const InputDecoration(
                    labelText: 'Note',
                    hintText: 'Add a note (optional)',
                    prefixIcon: Icon(
                      Icons.notes_outlined,
                    ),
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),

                const SizedBox(height: 30),

                // ==================================================
                // UPDATE BUTTON
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: ElevatedButton.icon(
                    onPressed: updateBill,

                    icon: const Icon(
                      Icons.save_outlined,
                    ),

                    label: const Text(
                      'Update Bill',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

