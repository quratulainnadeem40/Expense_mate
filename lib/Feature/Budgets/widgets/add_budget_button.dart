import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/budget_controller.dart';

class AddBudgetButton extends GetView<BudgetController> {
  const AddBudgetButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryController = TextEditingController();
    final amountController = TextEditingController();

    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {
        Get.defaultDialog(
          title: 'Add New Budget',
          content: Column(
            children: [
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          textConfirm: 'Add',
          onConfirm: () {
            if (categoryController.text.isNotEmpty && amountController.text.isNotEmpty) {
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