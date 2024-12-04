import 'package:get/get.dart';

import 'testing_logic.dart';

class TestingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TestingLogic());
  }
}
