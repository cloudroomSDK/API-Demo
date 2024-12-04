import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rtcsdk_demo/src/controller/app_controller.dart';
import 'package:rtcsdk_demo/src/controller/rtc_controller.dart';
import 'package:rtcsdk_demo/src/models/video_position.dart';
import 'package:rtcsdk_demo/src/models/video_status_changed.dart';
import 'package:rtcsdk_demo/src/utils/logger_util.dart';
import 'package:rtcsdk_demo/src/utils/utils.dart';
import 'package:rtcsdk/rtcsdk.dart';
import 'package:get/get.dart';
import 'package:rtcsdk_demo/src/widgets/video_component.dart';

class TestingLogic extends GetxController {
  final appLogic = Get.find<AppController>();
  final rtcLogic = Get.find<RTCController>();
  final String confId = Get.arguments['confId'];

  final GlobalKey<VideoComponentState> vcKey = GlobalKey<VideoComponentState>();
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
    vps = Utils.getVideoPosition(ctx: Get.context!);
    Function watchableVideos = Utils.debounce(getWatchableVideos);
    subs.addAll([
      rtcLogic.onAudioDevChanged.listen((_) {
        rtcLogic.openMic();
        rtcLogic.setSpeakerOut(false);

        testingMember();
        testingAudio();
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
          // rtcLogic.openCamera();
        }
        watchableVideos();
      }),
    ]);
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

  viewSetting() {
    int? vid = vcKey.currentState?.viewID;
    if (vid != null) {
      RtcSDK.videoManager.isPicEmpty(vid).then((bool isPicEmpty) {
        Logger.log('有图像才能获取Pic, isPicEmpty: $isPicEmpty');
        if (!isPicEmpty) {
          RtcSDK.videoManager.getShowPic(vid).then((Uint8List val) {
            Logger.log('Pic: $val');
          }).catchError((e) {
            Logger.log('Pic err: $e');
          });

          // 获取当前图像帧的显示时间戳
          RtcSDK.videoManager.getPicFrameTime(vid).then((int timestamp) {
            Logger.log('timestamp: $timestamp');
          });

          RtcSDK.videoManager.getPicWidth(vid).then((int width) {
            Logger.log('pic width: $width');
          });
          RtcSDK.videoManager.getPicHeight(vid).then((int height) {
            Logger.log('pic height: $height');
          });
        }
      });

      // 获取视频显示模式
      RtcSDK.videoManager.getScaleType(vid).then((int scaleType) {
        Logger.log('scaleType: $scaleType');
        RtcSDK.videoManager.setScaleType(vid, 1);
      });
    }
  }

  videoEffects() {
    RtcSDK.videoManager.getVideoEffects().then((VideoEffects effect) {
      Logger.log('VideoEffects: ${effect.toJson()}');
      effect.upsideDown = true;
      RtcSDK.videoManager.setVideoEffects(effect);
    });
  }

  void testingMember() async {
    String version = await RtcSDK.sdkManager.getVersion();
    debugPrint('version: $version');

    String myUserID = await RtcSDK.memberManager.getMyUserID();
    debugPrint('myUserID: $myUserID');

    List<MemberInfo> members = await RtcSDK.memberManager.getAllMembers();
    for (var mem in members) {
      debugPrint('mem: ${mem.nickName}');
      if (mem.userId != rtcLogic.userID) {
        RtcSDK.roomManager.kickout(mem.userId).then((int sdkErr) {
          if (sdkErr == 0) {
            debugPrint('列表踢一个最前面的: ${mem.nickName}');
          }
        });
        return;
      }
    }
  }

  void testingAudio() async {
    // 安卓开麦之后会把音频设置为通话音频，在这之后再来获取音量
    bool micIsSucc = await RtcSDK.audioManager.setMicVolume(150);
    debugPrint('micIsSucc: $micIsSucc');
    int micVolume = await RtcSDK.audioManager.getMicVolume();
    debugPrint('micVolume: $micVolume');
    bool speakerIsSucc = await RtcSDK.audioManager.setSpeakerVolume(150);
    debugPrint('speakerIsSucc: $speakerIsSucc');
    int speakerVolume = await RtcSDK.audioManager.getSpeakerVolume();
    debugPrint('speakerVolume: $speakerVolume');

    // 关闭所有人麦克风
    // RtcSDK.audioManager.setAllAudioClose();

    // 开始获取语音pcm数据
    // RtcSDK.audioManager
    //     .startGetAudioPCM(
    //         A_SIDE.MIC, GET_PCM_TYPE.CALLBACK, GetAudioPCMParam(EachSize: 320))
    //     .then((isSucc) {
    //   if (isSucc) {
    //     // 10秒后停止获取语音pcm数据
    //     Future.delayed(const Duration(seconds: 10), () {
    //       RtcSDK.audioManager.stopGetAudioPCM(A_SIDE.MIC);
    //     });
    //   }
    // });
  }
}
