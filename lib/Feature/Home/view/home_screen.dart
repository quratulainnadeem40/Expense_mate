import 'package:expense_mate/Feature/Home/widgets/balance_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:expense_mate/Feature/reports/controller/report_controller.dart';
// Other imports...

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reportController = Get.isRegistered<ReportController>()
        ? Get.find<ReportController>()
        : Get.put(ReportController());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card inside Obx
              Obx(
                () => BalanceCard(
                  totalBalance: reportController.totalBalance,
                  totalIncome: reportController.totalIncome,
                  totalExpense: reportController.totalExpense,
                ),
              ),

              const SizedBox(height: 24),

              // Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All'),
                  ),
                ],
              ),

              // Transaction List Container
              // Note: Agar List view use kar rahe hain, tou primary: false & shrinkWrap: true set karein
            ],
          ),
        ),
      ),
    );
  }
}