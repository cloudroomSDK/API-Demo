import 'package:get/get.dart';

import 'members_logic.dart';

class MembersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MembersLogic>(
      () => MembersLogic(),
    );
  }
}
