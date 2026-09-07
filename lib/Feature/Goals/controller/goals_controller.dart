import 'package:get/get.dart';
import '../model/goals_model.dart';

class GoalsController extends GetxController {
  var goals = <GoalModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSampleGoals();
  }

  void loadSampleGoals() {
    goals.assignAll([
      GoalModel(
        id: '1',
        title: 'New Laptop',
        targetAmount: 150000,
        savedAmount: 45000,
        targetDate: DateTime.now().add(const Duration(days: 90)),
      ),
      GoalModel(
        id: '2',
        title: 'Emergency Fund',
        targetAmount: 50000,
        savedAmount: 30000,
        targetDate: DateTime.now().add(const Duration(days: 30)),
      ),
    ]);
  }

  void addGoal(GoalModel goal) {
    goals.add(goal);
  }

  void addSavings(String id, double amount) {
    int index = goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      goals[index].savedAmount += amount;
      goals.refresh();
    }
  }
}