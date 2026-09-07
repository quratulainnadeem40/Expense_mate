import 'package:get/get.dart';
import '../controller/report_controller.dart';

class ReportBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportController>(() => ReportController());
  }
}