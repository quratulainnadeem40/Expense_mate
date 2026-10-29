import 'package:get/get.dart';

import '../controller/bills_reminders_controller.dart';

class BillsRemindersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BillsRemindersController>(
      () => BillsRemindersController(),
    );
  }
}