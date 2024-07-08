import 'package:get/get.dart';

import 'functions_logic.dart';

class FunctionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FunctionsLogic());
  }
}
