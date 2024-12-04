import 'package:get/get.dart';

import 'media_logic.dart';

class MediaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MediaLogic());
  }
}
