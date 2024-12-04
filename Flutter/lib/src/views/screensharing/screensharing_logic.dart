import 'dart:async';

import 'package:rtcsdk_demo/src/controller/app_controller.dart';
import 'package:rtcsdk_demo/src/controller/rtc_controller.dart';
import 'package:rtcsdk_demo/src/utils/logger_util.dart';
import 'package:rtcsdk/rtcsdk.dart';
import 'package:get/get.dart';

enum SHARE_STATE {
  none,
  share,
  view,
}

class ScreenSharingLogic extends GetxController {
  final appLogic = Get.find<AppController>();
  final rtcLogic = Get.find<RTCController>();
  final String confId = Get.arguments['confId'];

  Rx<SHARE_STATE> screenShareState = SHARE_STATE.none.obs;
  RxBool isScreenShare = false.obs;

  List<StreamSubscription> subs = [];

  @override
  onInit() {
    initEvt();
    super.onInit();
  }

  @override
  onClose() {
    if (isScreenShare.value) {
      RtcSDK.screenShareManager.stopScreenShare();
    }
    rtcLogic.exitMeeting();
    for (StreamSubscription sub in subs) {
      sub.cancel();
    }
    super.onClose();
  }

  initEvt() {
    getScreenShareState();
    setScreenShareCfg();
    subs.addAll([
      rtcLogic.onAudioDevChanged.listen((_) {
        rtcLogic.openMic();
        rtcLogic.setSpeakerOut(true);
      }),
      rtcLogic.onNotifyScreenShareStarted.listen((_) {
        isScreenShare.value = true;
        // 对方开的共享，状态改成观看
        // 如果是自己开的，通知到来这里已经是SHARE_STATE.share
        if (screenShareState.value == SHARE_STATE.none) {
          screenShareState.value = SHARE_STATE.view;
        }
      }),
      rtcLogic.onNotifyScreenShareStopped.listen((_) {
        isScreenShare.value = false;
        screenShareState.value = SHARE_STATE.none;
      }),
      rtcLogic.onNotifyScreenMarkStarted.listen((_) {}),
      rtcLogic.onNotifyScreenMarkStopped.listen((_) {}),
    ]);
  }

  getScreenShareState() async {
    bool isScreenShareStarted =
        await RtcSDK.screenShareManager.isScreenShareStarted();
    Logger.log('isScreenShareStarted: $isScreenShareStarted');
    isScreenShare.value = isScreenShareStarted;
    if (isScreenShareStarted) {
      screenShareState.value = SHARE_STATE.view;
    }
  }

  setScreenShareCfg() async {
    ScreenShareCfg cfg = await RtcSDK.screenShareManager.getScreenShareCfg();
    cfg.maxBps = 2000000;
    cfg.maxFps = 12;
    RtcSDK.screenShareManager.setScreenShareCfg(cfg);
  }

  startScreenShare() {
    RtcSDK.screenShareManager.startScreenShare();
  }

  stopScreenShare() {
    RtcSDK.screenShareManager.stopScreenShare();
  }

  switchScreenShare() {
    isScreenShare.toggle();
    if (isScreenShare.value) {
      startScreenShare();
      screenShareState.value = SHARE_STATE.share;
    } else {
      stopScreenShare();
      screenShareState.value = SHARE_STATE.none;
    }
  }
}
