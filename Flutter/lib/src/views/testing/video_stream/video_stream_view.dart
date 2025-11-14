import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:rtcsdk/rtcsdk.dart';
import 'package:rtcsdk_demo/src/resources/styles.dart';
import 'package:rtcsdk_demo/src/widgets/custom_appbar.dart';
import 'package:rtcsdk_demo/src/widgets/video_component.dart';

import 'video_stream_logic.dart';

class VideoStreamView extends GetView<VideoStreamLogic> {
  VideoStreamView({Key? key}) : super(key: key);

  final logic = Get.find<VideoStreamLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "视频大小流"),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 5.h,
              horizontal: 12.w,
            ),
            child: Text(
              '大流：',
              style: PageStyle.ts_14c333333,
            ),
          ),
          SizedBox(
            width: 375.w,
            height: 210.h,
            child: VideoComponent(
                usrVideoId: UsrVideoId(userId: logic.userID, videoID: -1)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 5.h,
              horizontal: 12.w,
            ),
            child: Text(
              '小流：',
              style: PageStyle.ts_14c333333,
            ),
          ),
          SizedBox(
            width: 375.w,
            height: 210.h,
            child: VideoComponent(
              qualityLv: 2,
              usrVideoId: UsrVideoId(userId: logic.userID, videoID: -1),
            ),
          ),
        ],
      ),
    );
  }
}
