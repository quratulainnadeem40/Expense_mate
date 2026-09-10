import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/expense_controller.dart';

class AddExpenseView extends GetView<ExpenseController> {
  const AddExpenseView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Expense / Income Toggle Switch
              Obx(() => Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.toggleType(true),
                        child: Container(
                          decoration: BoxDecoration(
                            color: controller.isExpense.value 
                                ? const Color(0xFF2EA44F) 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Expense',
                            style: TextStyle(
                              color: controller.isExpense.value 
                                  ? Colors.white 
                                  : (isDark ? Colors.white70 : Colors.black),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.toggleType(false),
                        child: Container(
                          decoration: BoxDecoration(
                            color: !controller.isExpense.value 
                                ? const Color(0xFF2EA44F) 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Income',
                            style: TextStyle(
                              color: !controller.isExpense.value 
                                  ? Colors.white 
                                  : (isDark ? Colors.white70 : Colors.black),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),

              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amount', style: TextStyle(color: theme.hintColor, fontSize: 13)),
                      TextField(
                        controller: controller.amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(color: theme.hintColor),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: theme.dividerColor),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF2EA44F)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text('Category', style: TextStyle(color: theme.hintColor, fontSize: 13)),
                      Obx(() {
                        final currentList = controller.isExpense.value 
                            ? controller.expenseCategories 
                            : controller.incomeCategories;
                            
                        return DropdownButtonFormField<String>(
                          value: controller.selectedCategory.value,
                          dropdownColor: theme.cardColor,
                          icon: Icon(Icons.arrow_drop_down, color: theme.iconTheme.color ?? Colors.grey),
                          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: theme.dividerColor),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF2EA44F)),
                            ),
                          ),
                          items: currentList.map((String val) {
                            return DropdownMenuItem<String>(
                              value: val, 
                              child: Text(val, style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) controller.selectedCategory.value = val;
                          },
                        );
                      }),
                      const SizedBox(height: 24),

                      Text('Payment Method', style: TextStyle(color: theme.hintColor, fontSize: 13)),
                      Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedPaymentMethod.value,
                        dropdownColor: theme.cardColor,
                        icon: Icon(Icons.arrow_drop_down, color: theme.iconTheme.color ?? Colors.grey),
                        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: theme.dividerColor),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF2EA44F)),
                          ),
                        ),
                        items: controller.paymentMethods.map((String val) {
                          return DropdownMenuItem<String>(
                            value: val, 
                            child: Text(val, style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) controller.selectedPaymentMethod.value = val;
                        },
                      )),
                      const SizedBox(height: 24),

                      Text('Note (Optional)', style: TextStyle(color: theme.hintColor, fontSize: 13)),
                      TextField(
                        controller: controller.noteController,
                        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                        decoration: InputDecoration(
                          hintText: 'e.g., Lunch with team',
                          hintStyle: TextStyle(color: theme.hintColor),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: theme.dividerColor),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF2EA44F)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2EA44F),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => controller.saveExpense(),
                  child: const Text(
                    'Save', 
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Center(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Cancel', style: TextStyle(color: theme.hintColor, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}