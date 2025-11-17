import 'package:get/get.dart';

import 'video_call_logic.dart';

class VideoCallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VideoCallLogic());
  }
}
