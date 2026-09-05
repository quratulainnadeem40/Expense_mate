import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../controller/bills_reminders_controller.dart';

class AddBillView extends StatefulWidget {
  const AddBillView({super.key});

  @override
  State<AddBillView> createState() => _AddBillViewState();
}

class _AddBillViewState extends State<AddBillView> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final amountController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  String selectedCategory = 'Utilities';
  String selectedRepeat = 'None';

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
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    super.dispose();
  }

  // ==========================================================
  // SELECT DATE
  // ==========================================================

  Future<void> selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // ==========================================================
  // SAVE BILL
  // ==========================================================

  Future<void> saveBill() async {
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

    await controller.addBill(
      name: nameController.text.trim(),
      amount: amount,
      dueDate: selectedDate,
      category: selectedCategory,
      repeat: selectedRepeat,
    );

    Get.back();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Bill',
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
                // TITLE
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
                  textInputAction: TextInputAction.next,
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

                Text(
                  'Due Date',
                  style: AppTextStyles.bodyLarge(isDark).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                InkWell(
                  onTap: selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 17,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                        ),

                        const SizedBox(width: 12),

                        Text(
                          '${selectedDate.day.toString().padLeft(2, '0')}/'
                          '${selectedDate.month.toString().padLeft(2, '0')}/'
                          '${selectedDate.year}',
                          style:
                              AppTextStyles.bodyLarge(isDark),
                        ),

                        const Spacer(),

                        const Icon(
                          Icons.arrow_drop_down_rounded,
                        ),
                      ],
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
                // SAVE BUTTON
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: saveBill,
                    icon: const Icon(
                      Icons.save_outlined,
                    ),
                    label: const Text(
                      'Save Bill',
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}