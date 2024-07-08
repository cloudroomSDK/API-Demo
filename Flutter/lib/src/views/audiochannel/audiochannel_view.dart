import 'package:rtcsdk_demo/src/controller/app_controller.dart';
import 'package:rtcsdk_demo/src/controller/rtc_controller.dart';
import 'package:rtcsdk_demo/src/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rtcsdk_demo/src/resources/styles.dart';
import 'package:get/get.dart';
import 'audiochannel_logic.dart';

class AudioChannel extends StatelessWidget {
  AudioChannel({Key? key}) : super(key: key);

  final rtcLogic = Get.find<RTCController>();
  final appLogic = Get.find<AppController>();
  final logic = Get.find<AudioChannelLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "房间号：${logic.confId}"),
      body: Container(
          color: PageStyle.c1d232f,
          child: Obx(() => Stack(children: [
                Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                          image: AssetImage("assets/images/voiceprint.png"),
                          fit: BoxFit.contain,
                        )),
                      ),
                    ),
                    Container(
                      height: 85.h,
                      color: Colors.black,
                      margin: EdgeInsets.only(top: 100.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 155.w,
                                  height: 30.h,
                                  child: ElevatedButton(
                                    style: PageStyle.getButtonStyle(),
                                    onPressed: rtcLogic.switchMic,
                                    child: Text(
                                      "${rtcLogic.isOpenMyMic.value ? '关闭' : '打开'}麦克风",
                                      style: PageStyle.ts_14cffffff,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                                SizedBox(
                                  width: 155.w,
                                  height: 30.h,
                                  child: ElevatedButton(
                                    style: PageStyle.getButtonStyle(),
                                    onPressed: rtcLogic.switchSpeakerOut,
                                    child: Text(
                                      "切换为${rtcLogic.isOpenMySpeaker.value ? '听筒' : '扬声器'}",
                                      style: PageStyle.ts_14cffffff,
                                    ),
                                  ),
                                )
                              ]),
                          Container(
                            width: 100.w,
                            height: 30.h,
                            margin: EdgeInsets.only(top: 7.h),
                            child: ElevatedButton(
                              style: PageStyle.getDangerButtonStyle(),
                              onPressed: logic.exit,
                              child: Text(
                                "挂断",
                                style: PageStyle.ts_14cffffff,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                    child: Center(
                  child: Container(
                    height: 100.h,
                    width: 205.w,
                    margin: EdgeInsets.only(top: 100.h),
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4.h),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 4.h),
                          child: Text(logic.nickName,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12.sp)),
                        ),
                        LinearProgressIndicator(
                          minHeight: 5,
                          value: logic.localVolume.value,
                          backgroundColor: const Color(0xff373F50),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xff09DB00)),
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                                top: ScreenUtil().setHeight(15),
                                bottom: ScreenUtil().setHeight(4)),
                            child: Text(logic.remoteNickName.value,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12.sp))),
                        LinearProgressIndicator(
                          minHeight: 5,
                          value: logic.remoteVolume.value,
                          backgroundColor: const Color(0xff373F50),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xff09DB00)),
                        ),
                      ],
                    ),
                  ),
                )),
              ]))),
    );
  }
}
