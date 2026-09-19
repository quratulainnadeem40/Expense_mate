import 'package:get/get.dart';
// Relative import ko package import se replace kiya hai
import 'package:expense_mate/Feature/reports/controller/report_controller.dart';

class ReportBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportController>(() => ReportController(), fenix: true);
  }
}