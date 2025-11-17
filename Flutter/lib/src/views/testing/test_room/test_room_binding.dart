import 'package:get/get.dart';

import 'test_room_logic.dart';

class TestRoomBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TestRoomLogic>(
      () => TestRoomLogic(),
    );
  }
}
