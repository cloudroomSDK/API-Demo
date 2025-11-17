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

  static Future<T?>? toDemoPage<T>(String target, int confID) {
    return Get.toNamed(target, arguments: {"confId": '$confID'});
  }

  static Future<T?>? toMembers<T>({int? type, String? action}) {
    return Get.toNamed(AppRoutes.MEMBERS, arguments: {
      "type": type ?? 0,
      "action": action ?? '',
    });
  }

  static Future<T?>? toVideoStream<T>(String userID) {
    return Get.toNamed(AppRoutes.VIDEOSTREAM, arguments: {"userID": userID});
  }

  static Future<T?>? toTest<T>() {
    return Get.toNamed(AppRoutes.TESTING);
  }

  static Future<T?>? toTestRoom<T>(int confID) {
    return Get.toNamed(AppRoutes.TESTROOM, arguments: {"confId": '$confID'});
  }

  static Future<T?>? toQueueList<T>() {
    return Get.toNamed(AppRoutes.QUEUELIST);
  }
}
