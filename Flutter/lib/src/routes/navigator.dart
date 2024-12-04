import 'package:get/get.dart';
import 'router.dart';

class AppNavigator {
  static void back() {
    Get.back();
  }

  static void toMain() {
    Get.offAllNamed(AppRoutes.FUNCTIONS);
  }

  static void backMain() {
    Get.until((route) => Get.currentRoute == AppRoutes.FUNCTIONS);
  }

  static void toJoinRoom(String target) {
    Get.toNamed(AppRoutes.JOINROOM, arguments: {"target": target});
  }

  static void toSetting() {
    Get.toNamed(AppRoutes.SETTINGS);
  }

  static Future<T?>? toSelLocRecord<T>({
    required String confId,
  }) {
    return Get.toNamed<T>(
      AppRoutes.LOCALRECOREDLIST,
      arguments: {
        'confId': confId,
      },
    );
  }

  static void toDemoPage(String target, int confID) {
    String confId = confID.toString();
    Get.toNamed(target, arguments: {"confId": confId});
  }
}
