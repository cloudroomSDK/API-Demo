import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'video_call_logic.dart';

class VideoCallPage extends StatelessWidget {
  final logic = Get.find<VideoCallLogic>();

  // Widget _buildCalling() => Column(
  //       children: [
  //         Column(
  //           children: [
  //             AvatarView(
  //               width: 120.w,
  //               height: 120.h,
  //               isCircle: false,
  //               url: logic.called.value.faceUrl,
  //               text: logic.called.value.nickname,
  //             ),
  //             10.verticalSpace,
  //             logic.called.value.nickname.toText
  //               ..style = Styles.ts_FFFFFF_16sp_medium,
  //           ],
  //         ),
  //         Spacer(),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceAround,
  //           children: [
  //             ClipOval(
  //               child: ImageRes.hangupBtn.toImage
  //                 ..width = 75.w
  //                 ..height = 75.h
  //                 ..fit = BoxFit.contain
  //                 ..onTap = () {
  //                   logic.onCancelCall();
  //                 },
  //             ),
  //             if (!logic.isCaller.value)
  //               ClipOval(
  //                 child: ImageRes.callBtn.toImage
  //                   ..width = 75.w
  //                   ..height = 75.h
  //                   ..fit = BoxFit.contain
  //                   ..onTap = () {
  //                     logic.onAcceptCall();
  //                   },
  //               ),
  //           ],
  //         )
  //       ],
  //     );

  @override
  Widget build(Object context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        padding: EdgeInsets.symmetric(vertical: 120.h),
        // child: Obx(
        //   () => _buildCalling(),
        // ),
      ),
    );
  }
}
