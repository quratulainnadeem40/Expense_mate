import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/goals_controller.dart';
import '../widgets/goals_card.dart';

class GoalsView extends GetView<GoalsController> {
  const GoalsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.goals.isEmpty) {
          return const Center(child: Text('No Goals Found'));
        }
        return ListView.builder(
          itemCount: controller.goals.length,
          itemBuilder: (context, index) {
            final goal = controller.goals[index];
            return GoalsCard(goal: goal);
          },
        );
      }),
    );
  }
}