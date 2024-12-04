import 'package:get/get.dart';

import 'videoconfig_logic.dart';

class VideoConfigBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VideoConfigLogic());
  }
}
