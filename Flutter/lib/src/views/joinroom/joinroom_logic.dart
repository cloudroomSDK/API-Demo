import 'package:permission_handler/permission_handler.dart';
import 'package:rtcsdk_demo/src/controller/permission_controller.dart';
import 'package:rtcsdk_demo/src/controller/rtc_controller.dart';
import 'package:rtcsdk_demo/src/resources/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rtcsdk_demo/src/routes/navigator.dart';
import 'package:rtcsdk/rtcsdk.dart';
import 'package:rtcsdk_demo/src/routes/router.dart';

class JoinRoomLogic extends GetxController {
  final String target = Get.arguments['target'];
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController confIdController;
  final rtcLogic = Get.find<RTCController>();
  final permissionLogic = Get.find<PermissionController>();

  final List<Widget> tips = [];
  final Map<String, List<Permission>> permissions = {
    AppRoutes.AUDIOCHANNEL: [
      Permission.microphone,
      Permission.phone,
    ],
    AppRoutes.VIDEOCHANNEL: [
      Permission.camera,
      Permission.microphone,
      Permission.phone,
    ],
    AppRoutes.VIDEOCONFIG: [
      Permission.camera,
      Permission.microphone,
      Permission.phone,
    ],
    AppRoutes.SCREENSHARING: [
      Permission.camera,
      Permission.microphone,
      Permission.phone,
      Permission.storage,
    ],
    AppRoutes.LOCALRECORED: [
      Permission.camera,
      Permission.microphone,
      Permission.phone,
      Permission.storage,
    ],
    AppRoutes.REMOTERECORD: [
      Permission.camera,
      Permission.microphone,
      Permission.phone,
    ],
    AppRoutes.MEDIA: [
      Permission.storage,
    ],
    AppRoutes.TESTING: [
      Permission.camera,
      Permission.microphone,
      Permission.phone,
      Permission.storage,
    ]
  };

  @override
  onInit() {
    confIdController = TextEditingController(text: rtcLogic.confID);
    if (target == AppRoutes.SCREENSHARING) {
      tips.addAll([
        Padding(
            padding: EdgeInsets.only(top: 25.h, bottom: 5.h),
            child: const Text("1、“进入房间”默认角色为“观看端”",
                style: TextStyle(color: PageStyle.c666666))),
        const Text("2、“创建房间”默认角色为“共享端”",
            style: TextStyle(color: PageStyle.c666666)),
      ]);
    }

    EasyLoading.dismiss();
    super.onInit();
  }

  @override
  void onClose() {
    confIdController.dispose();
    // 收起键盘
    FocusScope.of(Get.context!).requestFocus(FocusNode());
    super.onClose();
  }

  String? validator(value) {
    if (value == "") {
      return "请输入房间号";
    } else if (value?.length != 8) {
      return "请输入8位数字的房间号";
    }
    return null;
  }

  checkPermission() async {
    // if (permissions.containsKey(target)) {
    //   await permissionLogic.checkPermission(permissions[target]!);
    // }
    await permissionLogic.checkPermission([
      Permission.camera,
      Permission.microphone,
      Permission.phone,
      Permission.storage,
    ]);
  }

  enterRoom(int confid) async {
    EasyLoading.show();
    AppNavigator.toDemoPage(target, confid);
    int sdkErr = await rtcLogic.enterMeeting(confid);
    if (sdkErr != 0) {
      if (sdkErr == 807) await rtcLogic.exitMeeting();
      AppNavigator.back();
    }
    EasyLoading.dismiss();
  }

  tapEnterRoom() async {
    await checkPermission();
    await enterRoom(int.parse(confIdController.text));
  }

  createRoom() async {
    await checkPermission();
    EasyLoading.show();
    MeetInfo meetInfo = await RtcSDK.roomManager.createMeeting();
    if (meetInfo.sdkErr == 0) {
      enterRoom(meetInfo.confId);
    }
    EasyLoading.dismiss();
  }
}
