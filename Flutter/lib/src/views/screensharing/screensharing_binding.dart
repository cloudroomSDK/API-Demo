import 'package:get/get.dart';

import 'screensharing_logic.dart';

class ScreenSharingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ScreenSharingLogic());
  }
}
