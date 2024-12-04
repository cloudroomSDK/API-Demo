import 'package:rtcsdk_demo/src/controller/app_controller.dart';
import 'package:rtcsdk_demo/src/controller/rtc_controller.dart';
import 'package:rtcsdk_demo/src/widgets/custom_appbar.dart';
import 'package:rtcsdk_demo/src/widgets/share_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rtcsdk_demo/src/resources/styles.dart';
import 'package:get/get.dart';
import 'screensharing_logic.dart';

class ScreenSharing extends StatelessWidget {
  final appLogic = Get.find<AppController>();
  final rtcLogic = Get.find<RTCController>();
  final logic = Get.find<ScreenSharingLogic>();

  ScreenSharing({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PageStyle.c333333,
      appBar: CustomAppBar(title: "房间号：${logic.confId}"),
      body: Obx(
        () => logic.screenShareState.value != SHARE_STATE.view
            ? _buildShareScreen()
            : _buildShareScreening(),
      ),
    );
  }

  Widget _buildShareScreen() => Container(
        padding:
            EdgeInsets.only(top: 38.h, left: 30.w, right: 30.w, bottom: 36.h),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(bottom: 5.h),
              child: Text(
                "房间号：${logic.confId}",
                textAlign: TextAlign.left,
                style: PageStyle.ts_14cffffff,
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(bottom: 5.h),
              child: Text(
                "用户名：${rtcLogic.nickName}",
                textAlign: TextAlign.left,
                style: PageStyle.ts_14cffffff,
              ),
            ),
            // Container(
            //   alignment: Alignment.centerLeft,
            //   margin: EdgeInsets.only(bottom: 5.h),
            //   child: Text(
            //     "分辨率：${logic.confId}",
            //     textAlign: TextAlign.left,
            //     style: PageStyle.ts_14cffffff,
            //   ),
            // ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "请在其他设备上使用观众身份进入相同的房间观看",
                style: PageStyle.ts_14cffffff,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 52.h, bottom: 36.h),
              child: Text(
                "您正在共享屏幕",
                style: PageStyle.ts_16cffffff,
              ),
            ),
            SizedBox(
              width: 182.w,
              height: 65.h,
              child: ElevatedButton(
                onPressed: logic.switchScreenShare,
                style: logic.isScreenShare.value
                    ? PageStyle.getDangerButtonStyle(
                        textStyle: PageStyle.ts_16cffffff,
                      )
                    : PageStyle.getButtonStyle(
                        textStyle: PageStyle.ts_16cffffff,
                      ),
                child: Text(
                  "${logic.isScreenShare.value ? '停止' : '开始'}屏幕共享",
                  style: PageStyle.ts_16cffffff,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 125.w,
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
          ],
        ),
      );

  Widget _buildShareScreening() => Stack(
        children: [
          const ShareComponent(),
          Positioned(
            bottom: 38.h,
            width: 1.sw,
            child: Center(
              child: SizedBox(
                width: 125.w,
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
            ),
          )
        ],
      );
}
