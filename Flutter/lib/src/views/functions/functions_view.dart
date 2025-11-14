import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rtcsdk_demo/src/controller/rtc_controller.dart';
import 'package:rtcsdk_demo/src/resources/styles.dart';
import 'package:get/get.dart';
import 'package:rtcsdk_demo/src/routes/navigator.dart';
import 'package:rtcsdk_demo/src/routes/router.dart';
import 'functions_logic.dart';

class Functions extends StatelessWidget {
  Functions({Key? key}) : super(key: key);

  final logic = Get.find<FunctionsLogic>();
  final rtcLogic = Get.find<RTCController>();

  Widget btn(
    String text,
    String target, {
    Function? onPressed,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.5.w),
      width: 300.w,
      height: 40.h,
      child: ElevatedButton(
          style: PageStyle.getButtonStyle(),
          onPressed: rtcLogic.isLogined.value
              ? () {
                  if (onPressed != null) {
                    onPressed.call();
                  } else {
                    logic.toJoinRoomPage(target);
                  }
                }
              : null,
          child: Text(
            text,
            style: PageStyle.ts_14cffffff,
          )),
    );
  }

  Widget funTitle(String text) {
    return Container(
        width: double.infinity,
        color: PageStyle.cf2f2f2,
        child: Padding(
            padding: EdgeInsets.only(
              left: 15.5.w,
              top: 13.5.h,
              bottom: 8.h,
            ),
            child: Text(
              text,
              style: PageStyle.ts_14c999999,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("API DEMO"),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: PageStyle.c444444,
            ),
            onPressed: logic.toSettingPage,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Obx(() => Column(children: [
              funTitle("基础功能"),
              25.verticalSpace,
              btn("语音通话", AppRoutes.AUDIOCHANNEL),
              btn("视频通话", AppRoutes.VIDEOCHANNEL),
              btn("视频设置", AppRoutes.VIDEOCONFIG),
              btn("屏幕共享", AppRoutes.SCREENSHARING),
              25.verticalSpace,
              funTitle("高级功能"),
              25.verticalSpace,
              btn("本地录制", AppRoutes.LOCALRECORED),
              btn("云端录制", AppRoutes.REMOTERECORD),
              btn("视频播放", AppRoutes.MEDIA),
              btn("聊天", AppRoutes.CHAT),
              btn(
                "更多",
                AppRoutes.TESTING,
                onPressed: () {
                  AppNavigator.toTest();
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Text(logic.version.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: PageStyle.c666666)),
              ),
            ])),
      ),
    );
  }
}
