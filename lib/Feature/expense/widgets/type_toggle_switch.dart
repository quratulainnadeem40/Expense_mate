import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/expense_controller.dart';

class TypeToggleSwitch extends GetView<ExpenseController> {
  const TypeToggleSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      height: 44,
      padding: const EdgeInsets.all(3),
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
                  color: controller.isExpense.value ? const Color(0xFF2EA44F) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Expense',
                  style: TextStyle(
                    color: controller.isExpense.value ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
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
                  color: !controller.isExpense.value ? const Color(0xFF2EA44F) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Income',
                  style: TextStyle(
                    color: !controller.isExpense.value ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}