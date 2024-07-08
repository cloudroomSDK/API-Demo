import 'package:get/get.dart';

import 'audiochannel_logic.dart';

class AudioChannelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AudioChannelLogic());
  }
}
