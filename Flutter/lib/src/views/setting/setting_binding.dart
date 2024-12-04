import 'package:get/get.dart';

import 'setting_logic.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingsLogic());
  }
}
