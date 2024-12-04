import 'package:rtcsdk_demo/src/controller/app_controller.dart';
import 'package:rtcsdk_demo/src/controller/rtc_controller.dart';
import 'package:rtcsdk_demo/src/models/video_position.dart';
import 'package:rtcsdk_demo/src/widgets/custom_appbar.dart';
import 'package:rtcsdk_demo/src/widgets/video_component.dart';
import 'package:rtcsdk/rtcsdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rtcsdk_demo/src/resources/styles.dart';
import 'package:get/get.dart';
import 'remoterecord_logic.dart';

class RemoteRecord extends StatelessWidget {
  RemoteRecord({Key? key}) : super(key: key);
  final appLogic = Get.find<AppController>();
  final rtcLogic = Get.find<RTCController>();
  final logic = Get.find<RemoteRecordLogic>();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "房间号：${logic.confId}"),
      body: Obx(
        () => Stack(
          children: [
            VideoComponent(usrVideoId: rtcLogic.selfUsrVideoId),
            ...smallVideoComponents(),
            Positioned(
              width: 1.sw,
              height: 80.h,
              bottom: 0,
              child: Container(
                height: 80.h,
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
                color: Colors.black.withOpacity(0.8),
                child: Center(
                  child: ElevatedButton(
                    style: logic.isRecord.value
                        ? PageStyle.getDangerButtonStyle(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                          )
                        : PageStyle.getButtonStyle(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                          ),
                    onPressed: logic.switchRecord,
                    child: Text(
                      "${logic.isRecord.value ? '结束' : '云端'}录制",
                      style: PageStyle.ts_14cffffff,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
