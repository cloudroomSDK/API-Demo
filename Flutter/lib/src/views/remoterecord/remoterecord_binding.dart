import 'package:get/get.dart';

import 'remoterecord_logic.dart';

class RemoteRecordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RemoteRecordLogic());
  }
}
