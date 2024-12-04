import 'package:get/get.dart';

import 'localrecord_logic.dart';

class LocalRecordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LocalRecordLogic());
  }
}
