import 'package:get/get.dart';
import 'package:expense_mate/Feature/reports/controller/report_controller.dart';

class ReportBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportController>(
      () => ReportController(),
      fenix: true,
    );
  }
}