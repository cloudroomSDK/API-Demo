import 'package:get/get.dart';

import 'videochannel_logic.dart';

class VideoChannelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VideoChannelLogic());
  }
}
