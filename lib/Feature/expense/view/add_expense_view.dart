import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/expense_controller.dart';
import '../widgets/type_toggle_switch.dart';

class AddExpenseView extends GetView<ExpenseController> {
  const AddExpenseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TypeToggleSwitch(),
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
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          prefixText: '\$ ',
                          hintText: '0.00',
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2EA44F))),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text('Category', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedCategory.value,
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2EA44F))),
                        ),
                        items: controller.categories.map((String val) {
                          return DropdownMenuItem<String>(value: val, child: Text(val));
                        }).toList(),
                        onChanged: (val) => controller.selectedCategory.value = val!,
                      )),
                      const SizedBox(height: 20),

                      const Text('Payment Method', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedPaymentMethod.value,
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2EA44F))),
                        ),
                        items: controller.paymentMethods.map((String val) {
                          return DropdownMenuItem<String>(value: val, child: Text(val));
                        }).toList(),
                        onChanged: (val) => controller.selectedPaymentMethod.value = val!,
                      )),
                      const SizedBox(height: 20),

                      const Text('Note (Optional)', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      TextField(
                        controller: controller.noteController,
                        decoration: const InputDecoration(
                          hintText: 'e.g., Lunch with team',
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
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}