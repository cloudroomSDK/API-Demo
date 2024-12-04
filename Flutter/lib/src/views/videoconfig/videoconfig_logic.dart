import 'dart:async';

import 'package:rtcsdk_demo/src/controller/app_controller.dart';
import 'package:rtcsdk_demo/src/controller/rtc_controller.dart';
import 'package:rtcsdk_demo/src/models/video_position.dart';
import 'package:rtcsdk_demo/src/models/video_ratio.dart';
import 'package:rtcsdk_demo/src/models/video_status_changed.dart';
import 'package:rtcsdk_demo/src/routes/navigator.dart';
import 'package:rtcsdk_demo/src/utils/utils.dart';
import 'package:rtcsdk/rtcsdk.dart';
import 'package:get/get.dart';

class VideoConfigLogic extends GetxController {
  final appLogic = Get.find<AppController>();
  final rtcLogic = Get.find<RTCController>();
  final String confId = Get.arguments['confId'];

  RxList<VideoRatio> vratio = [
    VideoRatio(360, 640, 700), // 0.7M，取1024 * 0.7的话会有小数点
    VideoRatio(480, 848, 1024),
    VideoRatio(720, 1280, 2048),
    VideoRatio(1080, 1920, 4096),
  ].obs;

  VideoCfg? _cfg;
  RxDouble kbps = 0.0.obs;
  RxDouble fps = 15.0.obs;
  RxInt ratioidx = 0.obs;
  Rx<VideoRatio> get ratio => vratio[ratioidx.value].obs;
  List<VideoPosition> vps = [];
  RxList<UsrVideoId> uvids = <UsrVideoId>[].obs;
  List<StreamSubscription> subs = [];

  @override
  onInit() {
    initEvt();
    super.onInit();
  }

  @override
  onClose() {
    rtcLogic.exitMeeting();
    for (StreamSubscription sub in subs) {
      sub.cancel();
    }
    super.onClose();
  }

  initEvt() async {
    kbps.value = ratio.value.initbps;
    vps = Utils.getVideoPosition(ctx: Get.context!);
    Function watchableVideos = Utils.debounce(getWatchableVideos);
    subs.addAll([
      rtcLogic.onAudioDevChanged.listen((_) {
        rtcLogic.openMic();
        rtcLogic.setSpeakerOut(true);
      }),
      rtcLogic.onVideoStatusChanged.listen((VideoStatusChanged vsc) {
        if (vsc.userId != rtcLogic.userID &&
            (vsc.newStatus == VSTATUS.VOPEN ||
                vsc.newStatus == VSTATUS.VCLOSE)) {
          watchableVideos();
        }
      }),
      rtcLogic.onVideoDevChanged.listen((String userID) {
        if (userID == rtcLogic.userID) {
          switchRatio(0);
          rtcLogic.openCamera();
        }
        watchableVideos();
      }),
    ]);
  }

  setVideoCfg() async {
    _cfg ??= await RtcSDK.videoManager.getVideoCfg();
    _cfg!.size = VSize(width: ratio.value.width, height: ratio.value.height);
    _cfg!.fps = fps.value.toInt();
    _cfg!.maxbps = kbps.value.toInt() * 1000; // kbps -> bps
    await RtcSDK.videoManager.setVideoCfg(_cfg!);

    await RtcSDK.videoManager.getVideoEffects();
  }

  switchRatio(int idx) {
    ratioidx.value = idx;
    kbps.value = ratio.value.initbps;
    setVideoCfg();
  }

  changedKbps(double val) {
    kbps.value = val;
  }

  changedKbpsEnd(double val) {
    setVideoCfg();
  }

  changedFps(double val) {
    fps.value = val;
  }

  changedFpsEnd(double val) {
    setVideoCfg();
  }

  getWatchableVideos() async {
    List<UsrVideoId> usrVideoIds =
        await RtcSDK.videoManager.getWatchableVideos();
    List<UsrVideoId> uuvids = [];
    for (int i = 0; i < usrVideoIds.length; i++) {
      if (uuvids.length == 9) break;
      UsrVideoId item = usrVideoIds[i];
      if (item.userId != rtcLogic.userID) {
        uuvids.add(item);
      }
    }
    uvids
      ..clear()
      ..addAll(uuvids);
  }

  void exit() {
    AppNavigator.toMain();
  }
}
