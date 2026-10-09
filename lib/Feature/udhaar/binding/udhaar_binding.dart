import 'package:get/get.dart';

import '../controller/udhaar_controller.dart';

class UdhaarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UdhaarController>(() => UdhaarController());
  }
}
