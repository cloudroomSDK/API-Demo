import 'package:rtcsdk_demo/src/controller/app_controller.dart';
import 'package:rtcsdk_demo/src/controller/rtc_controller.dart';
import 'package:rtcsdk_demo/src/models/video_position.dart';
import 'package:rtcsdk_demo/src/models/video_ratio.dart';
import 'package:rtcsdk_demo/src/widgets/custom_appbar.dart';
import 'package:rtcsdk_demo/src/widgets/video_component.dart';
import 'package:rtcsdk/rtcsdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rtcsdk_demo/src/resources/styles.dart';
import 'package:get/get.dart';
import 'videoconfig_logic.dart';

class VideoConfig extends StatelessWidget {
  VideoConfig({Key? key}) : super(key: key);
  final appLogic = Get.find<AppController>();
  final rtcLogic = Get.find<RTCController>();
  final logic = Get.find<VideoConfigLogic>();

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
              left: 0,
              bottom: 0,
              child: Container(
                width: 1.sw,
                height: 222.h,
                decoration: const BoxDecoration(
                  color: Colors.black87,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 25.w,
                  vertical: 10.h,
                ),
                child: Obx(() => Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("分辨率", style: PageStyle.ts_14cffffff),
                        Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: _buildRatios(),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        _buildSliderContainer(
                          label: "码率",
                          suffixlabel: "${logic.kbps.round()}kbps",
                          child: SliderTheme(
                            data: const SliderThemeData(
                              trackHeight: 2.0,
                            ),
                            child: Slider(
                              value: logic.kbps.value,
                              min: logic.ratio.value.minkbps,
                              max: logic.ratio.value.maxkbps,
                              divisions: 100,
                              label: "${logic.kbps.round()}",
                              inactiveColor: PageStyle.cB1B1B1,
                              activeColor: PageStyle.mainColor,
                              thumbColor: PageStyle.mainColor,
                              onChanged: logic.changedKbps,
                              onChangeEnd: logic.changedKbpsEnd,
                            ),
                          ),
                        ),
                        _buildSliderContainer(
                          label: "帧率",
                          suffixlabel: "${logic.fps.round()}fps",
                          child: SliderTheme(
                            data: const SliderThemeData(
                              trackHeight: 2.0,
                            ),
                            child: Slider(
                              value: logic.fps.value,
                              min: 5,
                              max: 30,
                              divisions: 25,
                              label: "${logic.fps.round()}",
                              inactiveColor: PageStyle.cB1B1B1,
                              activeColor: PageStyle.mainColor,
                              thumbColor: PageStyle.mainColor,
                              onChanged: logic.changedFps,
                              onChangeEnd: logic.changedFpsEnd,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Center(
                          child: SizedBox(
                            width: 100.w,
                            height: 30.h,
                            child: ElevatedButton(
                              style: PageStyle.getDangerButtonStyle(),
                              onPressed: logic.exit,
                              child: Text(
                                "退出",
                                style: PageStyle.ts_14cffffff,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRatios() {
    List<Widget> items = [];
    for (var i = 0; i < logic.vratio.length; i++) {
      VideoRatio ratio = logic.vratio[i];
      Color color =
          i == logic.ratioidx.value ? PageStyle.mainColor : Colors.white;
      items.add(SizedBox(
        height: 25.h,
        child: OutlinedButton(
          style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0))),
              side: MaterialStateProperty.all(BorderSide(color: color)),
              padding: MaterialStateProperty.all(EdgeInsets.zero)),
          onPressed: () => logic.switchRatio(i),
          child: Text(ratio.text,
              style: TextStyle(
                color: color,
                fontSize: 12.sp,
              )),
        ),
      ));
    }
    return items;
  }

  Widget _buildSliderContainer({
    required String label,
    required String suffixlabel,
    required Widget child,
  }) {
    return Row(
      children: [
        SizedBox(
          child: Text(label, style: PageStyle.ts_14cffffff),
        ),
        Expanded(child: child),
        SizedBox(
          width: 65.w,
          child: Text(
            suffixlabel,
            style: PageStyle.ts_14cffffff,
          ),
        )
      ],
    );
  }
}
