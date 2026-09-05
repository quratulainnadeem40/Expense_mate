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

  late TextEditingController nameController;
  late TextEditingController amountController;

  late DateTime selectedDate;
  late String selectedCategory;
  late String selectedRepeat;

  final List<String> categories = [
    'Utilities',
    'Rent',
    'Internet',
    'Phone',
    'Subscription',
    'Insurance',
    'Education',
    'Other',
  ];

  final List<String> repeatOptions = [
    'None',
    'Monthly',
    'Yearly',
  ];

  @override
  void initState() {
    super.initState();

    // Load existing bill data
    nameController = TextEditingController(
      text: widget.bill.name,
    );

    amountController = TextEditingController(
      text: widget.bill.amount.toString(),
    );

    selectedDate = widget.bill.dueDate;

    selectedCategory = categories.contains(widget.bill.category)
        ? widget.bill.category
        : 'Other';

    selectedRepeat = repeatOptions.contains(widget.bill.repeat)
        ? widget.bill.repeat
        : 'None';
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
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

    if (amount == null) {
      return;
    }

    final controller = Get.find<BillsRemindersController>();

    final updatedBill = widget.bill.copyWith(
      name: nameController.text.trim(),
      amount: amount,
      dueDate: selectedDate,
      category: selectedCategory,
      repeat: selectedRepeat,
    );

    await controller.updateBill(updatedBill);

    Get.back();
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
                // BILL NAME
                // ==================================================

                TextFormField(
                  controller: nameController,

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

                    if (amount < 0) {
                      return 'Amount cannot be negative';
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
                // CATEGORY
                // ==================================================

                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,

                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(
                      Icons.category_outlined,
                    ),
                    border: OutlineInputBorder(),
                  ),

                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),

                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCategory = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 18),

                // ==================================================
                // REPEAT
                // ==================================================

                DropdownButtonFormField<String>(
                  initialValue: selectedRepeat,

                  decoration: const InputDecoration(
                    labelText: 'Repeat',
                    prefixIcon: Icon(
                      Icons.repeat_rounded,
                    ),
                    border: OutlineInputBorder(),
                  ),

                  items: repeatOptions.map((repeat) {
                    return DropdownMenuItem<String>(
                      value: repeat,
                      child: Text(repeat),
                    );
                  }).toList(),

                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedRepeat = value;
                      });
                    }
                  },
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