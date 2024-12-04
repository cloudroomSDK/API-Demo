import 'dart:async';

import 'package:rtcsdk_demo/src/controller/app_controller.dart';
import 'package:rtcsdk_demo/src/controller/permission_controller.dart';
import 'package:rtcsdk_demo/src/controller/rtc_controller.dart';
import 'package:rtcsdk_demo/src/models/error_def.dart';
import 'package:rtcsdk_demo/src/models/loc_mixer_output_info.dart';
import 'package:rtcsdk_demo/src/models/video_position.dart';
import 'package:rtcsdk_demo/src/models/video_status_changed.dart';
import 'package:rtcsdk_demo/src/utils/logger_util.dart';
import 'package:rtcsdk_demo/src/utils/utils.dart';
import 'package:rtcsdk/rtcsdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:gallery_saver/gallery_saver.dart';

class LocalRecordLogic extends GetxController {
  final appLogic = Get.find<AppController>();
  final rtcLogic = Get.find<RTCController>();
  final permissionLogic = Get.find<PermissionController>();
  final String confId = Get.arguments['confId'];

  TextEditingController fileNameController = TextEditingController();
  RxBool isRecord = false.obs;
  // 混图器Id，随机字符串
  String mixerId = "1";
  // 混图器配置
  MixerCfg cfg = MixerCfg(
      width: 360,
      height: 640,
      frameRate: 15,
      bitRate: 500000,
      defaultQP: 26,
      gop: 15);
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
    if (isRecord.value) {
      destroyLocMixer();
    }
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
          rtcLogic.openCamera();
        }
        watchableVideos();
      }),
      rtcLogic.onLocMixerStateChanged.listen((LocMixerState mixerState) {
        MIXER_OUTPUT_STATE state = mixerState.state;
        Logger.debug("mixerState: $state");
        if (state == MIXER_OUTPUT_STATE.OUTPUT_NONE) {
          // EasyLoading.showToast("StateChanged: OUTPUT_NONE");
        } else if (state == MIXER_OUTPUT_STATE.OUTPUT_CREATED) {
          // EasyLoading.showToast("StateChanged: OUTPUT_CREATED");
        } else if (state == MIXER_OUTPUT_STATE.OUTPUT_WRITING) {
          // EasyLoading.showToast("StateChanged: OUTPUT_WRITING");
        } else if (state == MIXER_OUTPUT_STATE.OUTPUT_CLOSED) {
          // EasyLoading.showToast("StateChanged: OUTPUT_CLOSED");
        } else if (state == MIXER_OUTPUT_STATE.OUTPUT_ERR) {
          // EasyLoading.showToast("StateChanged: OUTPUT_ERR");
          isRecord.value = false;
        }
      }),
      rtcLogic.onLocMixerOutputInfo
          .listen((LocMixerOutputInfo locMixerOutputInfo) {
        MixerOutputInfo mixerOutputInfo = locMixerOutputInfo.mixerOutputInfo;
        MIXER_OUTPUT_STATE state = mixerOutputInfo.state;
        Logger.debug("onLocMixerOutputInfo mixerState: $state");
        if (state == MIXER_OUTPUT_STATE.OUTPUT_NONE) {
          // EasyLoading.showToast("OUTPUT_NONE");
        } else if (state == MIXER_OUTPUT_STATE.OUTPUT_CREATED) {
          // EasyLoading.showToast("OUTPUT_CREATED");
        } else if (state == MIXER_OUTPUT_STATE.OUTPUT_WRITING) {
          // EasyLoading.showToast("OUTPUT_WRITING");
          // 保存一份到相册
          if (mixerOutputInfo.errCode == 0) {
            saveVideo(locMixerOutputInfo.nameOrUrl);
          }
        } else if (state == MIXER_OUTPUT_STATE.OUTPUT_CLOSED) {
          // EasyLoading.showToast("OUTPUT_CLOSED");
        } else if (state == MIXER_OUTPUT_STATE.OUTPUT_ERR) {
          // EasyLoading.showToast("OUTPUT_ERR");
          isRecord.value = false;
        }
      }),
    ]);

    genFileName();
  }

  // 保存到相册
  saveVideo(String path) async {
    try {
      bool? success = await GallerySaver.saveVideo(
        path,
        albumName: 'Flutter_ApiDemo',
      );
      if (success == true) {
        Logger.log("save video success");
      }
    } catch (e) {
      Logger.log("save video fail $e");
    }
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

    updateLocMixerContent();
  }

  switchRecord() {
    isRecord.toggle();
    if (isRecord.value) {
      startLocMixerContent();
    } else {
      destroyLocMixer();
      genFileName();
    }
  }

  // 生成文件名称
  genFileName() {
    fileNameController.text = Utils.dateFormat(DateTime.now(),
        format: "yyyy-MM-dd_hh-mm-ss_Flutter_$confId");
  }

  // 混图器内容
  List<MixerCotentRect> getMixerCotentRect() {
    int mcrWidth = cfg.width;
    int mcrHeight = cfg.height;
    final List<MixerCotentRect> mcr = [
      MixerCotentRect(
          userId: rtcLogic.userID,
          camId: -1,
          type: MIXER_VCONTENT_TYPE.MIXVTP_VIDEO,
          top: 0,
          left: 0,
          width: mcrWidth,
          height: mcrHeight),
      MixerCotentRect.timestamp(
        left: 0,
        top: 0,
        width: 175,
        height: 32,
      ), // 混时间戳
    ];

    for (int i = 0; i < uvids.length; i++) {
      UsrVideoId item = uvids[i];
      VideoPosition vp = vps[i];
      int top = (vp.ptop * mcrHeight).toInt();
      int left = (vp.pleft * mcrWidth).toInt();
      int width = (vp.pwidth * mcrWidth).toInt();
      int height = (vp.pheight * mcrHeight).toInt();

      MixerCotentRect mixercr = MixerCotentRect(
          userId: item.userId,
          camId: item.videoID,
          type: MIXER_VCONTENT_TYPE.MIXVTP_VIDEO,
          top: top,
          left: left,
          height: height,
          width: width);
      mcr.add(mixercr);
    }

    return mcr;
  }

  void startLocMixerContent() async {
    permissionLogic.storage(() async {
      if (fileNameController.text == "") {
        EasyLoading.showToast('录制名称不能为空');
        return;
      }
      final List<MixerCotentRect> mcr = getMixerCotentRect();
      // 创建混图器
      int sdkErr = await RtcSDK.recordManager.createLocMixer(mixerId, cfg, mcr);
      if (sdkErr == 0) {
        // 录像文件目录
        String path = await Utils.moviesStorageDirectories();
        String fileName = "$path/${fileNameController.text}.mp4";
        Logger.log("Loc fileName: $fileName");
        // 输出配置
        MixerOutPutCfg mixerOutPutCfg = MixerOutPutCfg(
            type: MIXER_OUTPUT_TYPE.MIXOT_FILE, fileName: fileName);
        List<MixerOutPutCfg> mixerOutPutCfgs = [mixerOutPutCfg];
        // 添加输出到录像文件
        int addLocSdkErr = await RtcSDK.recordManager
            .addLocMixerOutput(mixerId, mixerOutPutCfgs);
        if (addLocSdkErr != 0) {
          EasyLoading.showToast(
              'createLocMixer: ${ErrorDef.getMessage(addLocSdkErr)}');
        }
      } else {
        EasyLoading.showToast('createLocMixer: ${ErrorDef.getMessage(sdkErr)}');
      }
    }, () {
      EasyLoading.showToast('请打开存储权限');
    });
  }

  void updateLocMixerContent() {
    // 是否在录制，是的话要更新混图器
    if (isRecord.value) {
      List<MixerCotentRect> mcr = getMixerCotentRect();
      RtcSDK.recordManager.updateLocMixerContent(mixerId, mcr);
    }
  }

  void destroyLocMixer() {
    RtcSDK.recordManager.destroyLocMixer(mixerId);
  }
}
