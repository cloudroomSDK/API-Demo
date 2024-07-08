import 'package:rtcsdk_demo/src/controller/app_controller.dart';
import 'package:rtcsdk_demo/src/controller/rtc_controller.dart';
import 'package:rtcsdk_demo/src/models/video_position.dart';
import 'package:rtcsdk_demo/src/widgets/custom_appbar.dart';
import 'package:rtcsdk_demo/src/widgets/custom_text_formfield.dart';
import 'package:rtcsdk_demo/src/widgets/touch_close_keyboard.dart';
import 'package:rtcsdk_demo/src/widgets/video_component.dart';
import 'package:rtcsdk/rtcsdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rtcsdk_demo/src/resources/styles.dart';
import 'package:get/get.dart';
import 'localrecord_logic.dart';

class LocalRecord extends StatelessWidget {
  LocalRecord({Key? key}) : super(key: key);
  final appLogic = Get.find<AppController>();
  final rtcLogic = Get.find<RTCController>();
  final logic = Get.find<LocalRecordLogic>();

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
        () => TouchCloseSoftKeyboard(
          child: Stack(
            children: [
              VideoComponent(usrVideoId: rtcLogic.selfUsrVideoId),
              ...smallVideoComponents(),
              Positioned(
                  width: 1.sw,
                  height: 80.h,
                  bottom: 0,
                  child: Container(
                      height: 80.h,
                      padding:
                          EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
                      color: Colors.black.withOpacity(0.8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "请输入文件名",
                              style: PageStyle.ts_14cffffff,
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Container(
                                height: 30.h,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4.w))),
                                child: CustomTextFormField(
                                  controller: logic.fileNameController,
                                ),
                              )),
                              Container(
                                height: 30.h,
                                margin: EdgeInsets.only(left: 10.w),
                                child: ElevatedButton(
                                    style: logic.isRecord.value
                                        ? PageStyle.getDangerButtonStyle()
                                        : PageStyle.getButtonStyle(),
                                    onPressed: logic.switchRecord,
                                    child: Text(
                                      "${logic.isRecord.value ? '停止' : '开始'}录制",
                                      style: PageStyle.ts_14cffffff,
                                    )),
                              )
                            ],
                          ),
                        ],
                      )))
            ],
          ),
        ),
      ),
    );
  }
}
