import 'dart:async';

import 'package:get/get.dart';
import 'package:rtcsdk_demo/src/controller/rtc_controller.dart';
import 'package:rtcsdk_demo/src/models/video_status_changed.dart';

class VideoStreamLogic extends GetxController {
  final rtcLogic = Get.find<RTCController>();
  final String userID = Get.arguments['userID'];
  List<StreamSubscription> subs = [];

  @override
  void onInit() {
    subs.addAll([
      rtcLogic.onVideoStatusChanged.listen((VideoStatusChanged vsc) {}),
      rtcLogic.onVideoDevChanged.listen((String userID) {}),
    ]);
    super.onInit();
  }

  @override
  onClose() {
    for (StreamSubscription sub in subs) {
      sub.cancel();
    }
    super.onClose();
  }
}
