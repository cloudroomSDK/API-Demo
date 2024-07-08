import 'package:rtcsdk_demo/src/controller/app_controller.dart';
import 'package:get/get.dart';
import 'package:rtcsdk_demo/src/routes/navigator.dart';
import 'package:package_info_plus/package_info_plus.dart';

class FunctionsLogic extends GetxController {
  final appLogic = Get.find<AppController>();
  RxString version = "".obs;
  RxBool isrunback = false.obs;

  @override
  onInit() {
    _getPlatform();
    appLogic.backgroundSubject.listen((isback) {
      isrunback.value = isback;
    });
    super.onInit();
  }

  _getPlatform() async {
    PackageInfo info = await PackageInfo.fromPlatform();
    version.value = "版本号：${info.version}";
  }

  void toJoinRoomPage(String target) {
    AppNavigator.toJoinRoom(target);
  }

  void toSettingPage() {
    AppNavigator.toSetting();
  }
}
