import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/budget_controller.dart';

class AddBudgetButton extends GetView<BudgetController> {
  const AddBudgetButton({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryController = TextEditingController();
    final amountController = TextEditingController();

    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {
        Get.defaultDialog(
          title: 'Add New Budget'.tr,
          content: Column(
            children: [
              TextField(
                controller: categoryController,
                decoration: InputDecoration(labelText: 'Category'.tr),
              ),
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: 'Amount'.tr),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          textConfirm: 'Add'.tr,
          onConfirm: () {
            if (categoryController.text.isNotEmpty &&
                amountController.text.isNotEmpty) {
              controller.addNewBudget(
                categoryController.text,
                double.parse(amountController.text),
              );
              Get.back();
            }
          },
        );
      },
    );
  }
}
