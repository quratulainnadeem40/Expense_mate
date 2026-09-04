import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/expense_controller.dart';

class AddExpenseView extends GetView<ExpenseController> {
  const AddExpenseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  color: const Color(0xFFF2F4F7),
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
                              color: controller.isExpense.value ? Colors.white : Colors.black,
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
                              color: !controller.isExpense.value ? Colors.white : Colors.black,
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
                      const Text('Amount', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      TextField(
                        controller: controller.amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2EA44F))),
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text('Category', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      Obx(() {
                        final currentList = controller.isExpense.value 
                            ? controller.expenseCategories 
                            : controller.incomeCategories;
                            
                        return DropdownButtonFormField<String>(
                          value: controller.selectedCategory.value,
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                          decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2EA44F))),
                          ),
                          items: currentList.map((String val) {
                            return DropdownMenuItem<String>(value: val, child: Text(val));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) controller.selectedCategory.value = val;
                          },
                        );
                      }),
                      const SizedBox(height: 24),

                      const Text('Payment Method', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedPaymentMethod.value,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2EA44F))),
                        ),
                        items: controller.paymentMethods.map((String val) {
                          return DropdownMenuItem<String>(value: val, child: Text(val));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) controller.selectedPaymentMethod.value = val;
                        },
                      )),
                      const SizedBox(height: 24),

                      const Text('Note (Optional)', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      TextField(
                        controller: controller.noteController,
                        decoration: const InputDecoration(
                          hintText: 'e.g., Lunch with team',
                          hintStyle: TextStyle(color: Colors.black38),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2EA44F))),
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
                  child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),

              Center(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}