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
      appBar: CustomAppBar(
        title: "房间号：${logic.confId}",
        actions: [
          IconButton(
              icon: const Icon(Icons.group_outlined),
              onPressed: () {
                logic.toMembers();
              }),
        ],
      ),
      body: Obx(
        () => Stack(
          children: [
            VideoComponent(
              usrVideoId: rtcLogic.selfUsrVideoId,
              onViewID: logic.onMyViewId,
            ),
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
                child: Stack(
                  children: [
                    Obx(() => Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ..._buildPanel(),
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
                    Positioned(
                      top: -10.h,
                      right: -10.w,
                      child: IconButton(
                          color: Colors.white,
                          icon: const Icon(Icons.sync_alt),
                          onPressed: () {
                            logic.showMoreFunc();
                          }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPanel() {
    if (!logic.moreFunc.value) {
      return [
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
      ];
    }

    return [
      Text("配置", style: PageStyle.ts_14cffffff),
      Padding(
        padding: EdgeInsets.only(top: 8.h),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          // _buildSelect<int>(
          //     label: '镜像',
          //     hint: Obx(
          //       () => Text(
          //         logic.mirrorLabal.value,
          //         style: PageStyle.ts_12cffffff,
          //       ),
          //     ),
          //     items: logic.mirrors,
          //     onChanged: (int? val) {
          //       if (val != null) {
          //         logic.mirror.value = val;
          //         logic.setEffect();
          //       }
          //     }),
          // Obx(
          //   () => _builCheck(
          //     '上下翻转',
          //     logic.upsideDown.value,
          //     onPressed: () {
          //       logic.upsideDown.toggle();
          //       logic.setEffect();
          //     },
          //   ),
          // ),
          _buildSelect<int>(
            label: "旋转",
            hint: Obx(
              () => Text(
                logic.degreeLabal.value,
                style: PageStyle.ts_12cffffff,
              ),
            ),
            items: logic.degrees,
            onChanged: (int? val) {
              if (val != null) {
                logic.degree.value = val;
                logic.setEffect();
              }
            },
          ),
          15.horizontalSpace,
          Obx(
            () => _builCheck(
              '降噪',
              logic.denoise.value,
              onPressed: () {
                logic.denoise.toggle();
                logic.setEffect();
              },
            ),
          ),
        ]),
      ),
      5.verticalSpace,
      Row(
        children: [
          _buildSelect<int>(
            label: "大小流",
            hint: Obx(
              () => Text(
                logic.sizeValue.value.label,
                style: PageStyle.ts_12cffffff,
              ),
            ),
            items: logic.sizes,
            onChanged: logic.setLocVideoAttributes,
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildRatios() {
    List<Widget> items = [];
    for (var i = 0; i < logic.vratio.length; i++) {
      VideoRatio ratio = logic.vratio[i];
      items.add(_buildBtn(ratio.text, i == logic.ratioidx.value,
          onPressed: () => logic.switchRatio(i)));
    }
    return items;
  }

  Widget _buildBtn(String text, bool active, {void Function()? onPressed}) {
    Color color = active ? PageStyle.mainColor : Colors.white;
    return SizedBox(
      height: 25.h,
      child: OutlinedButton(
        style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0))),
            side: MaterialStateProperty.all(BorderSide(color: color)),
            padding: MaterialStateProperty.all(EdgeInsets.zero)),
        onPressed: onPressed,
        child: Text(text,
            style: TextStyle(
              color: color,
              fontSize: 12.sp,
            )),
      ),
    );
  }

  Widget _builCheck(String text, bool active, {void Function()? onPressed}) {
    return SizedBox(
      height: 28.h,
      child: OutlinedButton(
        style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0))),
            side: MaterialStateProperty.all(
                const BorderSide(color: Colors.white)),
            padding: MaterialStateProperty.all(EdgeInsets.zero)),
        onPressed: onPressed,
        child: Row(
          children: [
            10.horizontalSpace,
            Text(
              text,
              style: PageStyle.ts_12cffffff,
            ),
            Checkbox(
                value: active,
                onChanged: (val) {
                  onPressed?.call();
                }),
          ],
        ),
      ),
    );
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

  Widget _buildSelect<T>({
    String? label,
    required List<SelectItemMode> items,
    required void Function(T?)? onChanged,
    required Widget hint,
  }) {
    return SizedBox(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label',
            style: PageStyle.ts_14cffffff,
          ),
          5.horizontalSpace,
          Container(
            height: 28.h,
            width: 80.w,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButton<T>(
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 30,
              iconEnabledColor: Colors.white,
              hint: hint,
              padding: EdgeInsets.only(left: 10.w),
              isDense: true,
              isExpanded: true,
              items: (items
                  .map((item) => DropdownMenuItem<T>(
                        value: item.value,
                        child: Text(
                          item.label,
                          style: PageStyle.ts_12c333333,
                        ),
                      ))
                  .toList()),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
