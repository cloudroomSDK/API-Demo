import 'package:get/get.dart';

import 'record_list_logic.dart';

class RecordListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RecordListLogic());
  }
}
