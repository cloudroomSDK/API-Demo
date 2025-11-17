import 'package:rtcsdk/rtcsdk.dart';
import 'package:rtcsdk_demo/src/controller/app_controller.dart';
import 'package:rtcsdk_demo/src/controller/rtc_controller.dart';
import 'package:rtcsdk_demo/src/models/video_position.dart';
import 'package:rtcsdk_demo/src/widgets/custom_appbar.dart';
import 'package:rtcsdk_demo/src/widgets/video_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rtcsdk_demo/src/resources/styles.dart';
import 'package:get/get.dart';

import 'test_room_logic.dart';

class TestRoomView extends GetView<TestRoomLogic> {
  TestRoomView({Key? key}) : super(key: key);

  final appLogic = Get.find<AppController>();
  final rtcLogic = Get.find<RTCController>();
  final logic = Get.find<TestRoomLogic>();

  List<Widget> smallVideoComponents() {
    List<Widget> items = [];
    for (int i = 0; i < logic.uvids.length; i++) {
      UsrVideoId item = logic.uvids[i];
      VideoPosition vps = logic.vps[i];
      items.add(
        Positioned(
          left: vps.left,
          top: vps.top,
          width: vps.width,
          height: vps.height,
          child: VideoComponent(
              key: Key('${item.userId}_${item.videoID}'), usrVideoId: item),
        ),
      );
    }
    return items;
  }

  Widget button({
    void Function()? onPressed,
    Widget? child,
  }) {
    return SizedBox(
      width: 155.w,
      height: 30.h,
      child: ElevatedButton(
        style: PageStyle.getButtonStyle(),
        onPressed: onPressed,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "房间号：${logic.confId}"),
      body: Obx(() => Stack(
            children: [
              VideoComponent(
                usrVideoId: rtcLogic.selfUsrVideoId,
                key: logic.vcKey,
              ),
              ...smallVideoComponents(),
              Positioned(
                left: 0,
                bottom: 0,
                child: Container(
                  width: 1.sw,
                  height: 175.h,
                  color: Colors.black54,
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          button(
                            onPressed: logic.toMembers,
                            child: Text(
                              "成员列表",
                              style: PageStyle.ts_14cffffff,
                            ),
                          ),
                          // SizedBox(width: 10.w),
                          // button(
                          //   onPressed: logic.viewSetting,
                          //   child: Text(
                          //     "viewSetting",
                          //     style: PageStyle.ts_14cffffff,
                          //   ),
                          // ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          button(
                            onPressed: rtcLogic.switchDefaultVideo,
                            child: Text(
                              "${rtcLogic.myCameraPosition.value == CAMERA_POSITION.FRONT ? '后置' : '前置'}摄像头",
                              style: PageStyle.ts_14cffffff,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          button(
                            onPressed: rtcLogic.switchCamera,
                            child: Text(
                              "${rtcLogic.isOpenMyCamera.value ? '关闭' : '打开'}摄像头",
                              style: PageStyle.ts_14cffffff,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          button(
                            onPressed: rtcLogic.switchMic,
                            child: Text(
                              "${rtcLogic.isOpenMyMic.value ? '关闭' : '打开'}麦克风",
                              style: PageStyle.ts_14cffffff,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          button(
                            onPressed: rtcLogic.switchSpeakerOut,
                            child: Text(
                              "切换为${rtcLogic.isOpenMySpeaker.value ? '听筒' : '扬声器'}",
                              style: PageStyle.ts_14cffffff,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }
}
