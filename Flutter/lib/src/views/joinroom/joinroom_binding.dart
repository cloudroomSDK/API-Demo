import 'package:get/get.dart';

import 'joinroom_logic.dart';

class JoinRoomBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => JoinRoomLogic());
  }
}
