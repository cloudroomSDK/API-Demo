import 'package:get/get.dart';

import 'queue_list_logic.dart';

class QueueListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QueueListLogic>(
      () => QueueListLogic(),
    );
  }
}
