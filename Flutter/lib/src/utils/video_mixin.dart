import 'dart:async';

import 'package:get/get.dart';
import 'package:rtcsdk/rtcsdk.dart';
import 'package:rtcsdk_demo/src/models/video_position.dart';

class VideoMixin {
  List<VideoPosition> vps = [];
  RxList<UsrVideoId> uvids = <UsrVideoId>[].obs;
  List<StreamSubscription> subs = [];
  String myUserId = "";

  initVideoMixin(String userId) {
    myUserId = userId;
  }

  getWatchableVideos() async {
    List<UsrVideoId> usrVideoIds =
        await RtcSDK.videoManager.getWatchableVideos();
    List<UsrVideoId> uuvids = [];
    for (int i = 0; i < usrVideoIds.length; i++) {
      if (uuvids.length == 9) break;
      UsrVideoId item = usrVideoIds[i];
      if (item.userId != myUserId) {
        uuvids.add(item);
      }
    }
    uvids
      ..clear()
      ..addAll(uuvids);
  }
}
