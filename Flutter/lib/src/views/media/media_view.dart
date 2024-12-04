import 'package:rtcsdk/rtcsdk.dart';
import 'package:rtcsdk_demo/src/controller/app_controller.dart';
import 'package:rtcsdk_demo/src/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rtcsdk_demo/src/resources/styles.dart';
import 'package:get/get.dart';
import 'package:rtcsdk_demo/src/widgets/media_component.dart';
import 'media_logic.dart';

class Media extends StatelessWidget {
  Media({Key? key}) : super(key: key);
  final appLogic = Get.find<AppController>();
  final logic = Get.find<MediaLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PageStyle.backgroundColor1,
      appBar: CustomAppBar(title: "房间号：${logic.confId}"),
      body: Obx(() => Stack(
            children: [
              logic.mediaState.value != MEDIA_STATE.MEDIA_STOP
                  ? _buildPlayMedia()
                  : _buildPickMedia(),
              Positioned(
                width: 1.sw,
                height: 80.h,
                bottom: 0,
                left: 0,
                child: Container(
                  height: 80.h,
                  padding:
                      EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
                  color: Colors.black.withOpacity(0.8),
                  child: Center(
                    child: SizedBox(
                      child: ElevatedButton(
                        style: logic.isPlay
                            ? PageStyle.getDangerButtonStyle(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                              )
                            : PageStyle.getButtonStyle(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                              ),
                        onPressed: logic.switchPlay,
                        child: Text(
                          "${logic.isPlay ? '停止' : '开始'}播放",
                          style: PageStyle.ts_14cffffff,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildPickMedia() => Positioned(
        top: 156.h,
        left: 52.5.w,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 22.h, horizontal: 25.w),
          width: 270.w,
          height: 92.5.h,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(8.w))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "选择文件：",
                style: PageStyle.ts_14c333333,
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  SizedBox(
                    width: 66.5.w,
                    height: 20.h,
                    child: ElevatedButton(
                      onPressed: logic.pickFile,
                      style: PageStyle.getButtonStyle(
                        backgroundColor: const Color(0xFFD9D9D9),
                      ),
                      child: Text(
                        "浏览...",
                        style: PageStyle.ts_12c333333,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  SizedBox(
                    width: 140.w,
                    child: Text(
                      logic.fileName.value == ''
                          ? "未选择文件"
                          : logic.fileName.value,
                      style: PageStyle.ts_12c333333,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildPlayMedia() => Stack(
        children: [
          GestureDetector(
            onPanDown: (DragDownDetails details) {
              logic.showHandleBtn();
            },
            child: const Center(
              child: MediaComponent(),
            ),
          ),
          Positioned(
              child: SizedBox(
            child: logic.isShowBtn.value ||
                    logic.mediaState.value == MEDIA_STATE.MEDIA_PAUSE
                ? GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: 1.sw,
                      height: 1.sh,
                      child: Center(
                        child: IconButton(
                          onPressed: () {
                            bool isPause = logic.mediaState.value !=
                                MEDIA_STATE.MEDIA_PAUSE;
                            logic.pausePlayMedia(isPause);
                          },
                          icon: Icon(
                            logic.mediaState.value == MEDIA_STATE.MEDIA_PAUSE
                                ? Icons.play_circle_outlined
                                : Icons.pause_circle_outlined,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                : null,
          )),
        ],
      );
}
