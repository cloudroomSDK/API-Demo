import 'dart:async';

import 'package:rtcsdk_demo/src/controller/app_controller.dart';
import 'package:rtcsdk_demo/src/controller/rtc_controller.dart';
import 'package:rtcsdk_demo/src/models/cloud_mixer_state.dart';
import 'package:rtcsdk_demo/src/models/video_position.dart';
import 'package:rtcsdk_demo/src/models/video_status_changed.dart';
import 'package:rtcsdk_demo/src/utils/logger_util.dart';
import 'package:get/get.dart';
import 'package:rtcsdk_demo/src/utils/utils.dart';
import 'package:rtcsdk/rtcsdk.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class RemoteRecordLogic extends GetxController {
  final appLogic = Get.find<AppController>();
  final rtcLogic = Get.find<RTCController>();
  final String confId = Get.arguments['confId'];
  RxBool isRecord = false.obs;
  // 混图器Id，随机字符串
  String? mixerId;
  int mixerWidth = 360;
  int mixerHeight = 640;
  CloudMixerCfg cloudMixerCfg = CloudMixerCfg(mode: CLOUDMIXER_MODE.CONFLUENCE);

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
      destroyCloudMixer();
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
      // 云端录制、云端直播状态变化通知
      rtcLogic.onCreateCloudMixerFailed.listen((String mixerID) {
        EasyLoading.showToast('启动云端录制、云端直播失败通知 $mixerID');
        Logger.log('启动云端录制、云端直播失败通知 $mixerID');
      }),
      // 开启云端混图器后，房间内所有人都将收到cloudMixerStateChanged通知进入MIXER_STARTING（启动中状态）
      rtcLogic.onCloudMixerStateChanged
          .listen((CloudMixerState cloudMixerState) {
        EasyLoading.showToast(
            '云端录制: ${cloudMixerState.state}__${cloudMixerState.mixerID}');
        Logger.log(
            '云端录制: ${cloudMixerState.state}__${cloudMixerState.mixerID}');
      }),
      // 云端录制、云端直播配置变化通知
      rtcLogic.onCloudMixerInfoChanged.listen((String mixerID) {
        EasyLoading.showToast('云端录制、云端直播配置变化通知');
        RtcSDK.recordManager
            .getCloudMixerInfo(mixerID)
            .then((CloudMixerInfo info) {
          Logger.log('getCloudMixerInfo: ${info.toJson()}');
        });
      }),
      // 云端录制文件、云端直播输出变化通知
      rtcLogic.onCloudMixerOutputInfoChanged
          .listen((CloudMixerOutputInfo cloudMixerOutputInfo) {
        EasyLoading.showToast(
            '云端录制文件、云端直播输出变化通知 ${cloudMixerOutputInfo.state}');
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

    updateCloudMixerContent();
  }

  switchRecord() {
    isRecord.toggle();
    if (isRecord.value) {
      createCloudMixer();
    } else {
      destroyCloudMixer();
    }
  }

  // 混图器内容
  List<MutiMixerContent> getMutiMixerContent() {
    List<MutiMixerContent> mmc = [
      MutiMixerContent(
        width: mixerWidth,
        height: mixerHeight,
        left: 0,
        top: 0,
        type: MIXER_VCONTENT_TYPE.MIXVTP_VIDEO,
        keepAspectRatio: KEEP_ASPECT_RATIO.KEEP,
        mutiMixerContentParams:
            MutiMixerContentParams(camid: "${rtcLogic.userID}.-1"),
      ),
      MutiMixerContent.timestamp(
        left: 0,
        top: 0,
        width: 175,
        height: 32,
        keepAspectRatio: KEEP_ASPECT_RATIO.KEEP,
      ), // 混时间戳
    ];

    for (int i = 0; i < uvids.length; i++) {
      UsrVideoId item = uvids[i];
      VideoPosition vp = vps[i];
      int top = (vp.ptop * mixerHeight).toInt();
      int left = (vp.pleft * mixerWidth).toInt();
      int width = (vp.pwidth * mixerWidth).toInt();
      int height = (vp.pheight * mixerHeight).toInt();

      MutiMixerContent mixercr = MutiMixerContent(
        top: top,
        left: left,
        height: height,
        width: width,
        type: MIXER_VCONTENT_TYPE.MIXVTP_VIDEO,
        keepAspectRatio: KEEP_ASPECT_RATIO.KEEP,
        mutiMixerContentParams: MutiMixerContentParams(
          camid: "${item.userId}.${item.videoID}",
        ),
      );
      mmc.add(mixercr);
    }

    return mmc;
  }

  createCloudMixer() async {
    // 录像名称
    String dir = Utils.dateFormat(
      DateTime.now(),
      format: "yyyy-MM-dd",
    );
    String svrPathName = '$dir/${Utils.dateFormat(
      DateTime.now(),
      format: "yyyy-MM-dd_hh-mm-ss_Flutter_$confId",
    )}';
    cloudMixerCfg.videoFileCfg = CloudMixerVideoFileCfg.confluence(
      svrPathName: '$svrPathName.mp4',
      vWidth: mixerWidth,
      vHeight: mixerHeight,
      layoutConfig: getMutiMixerContent(),
    );

    // 单流的，mode得改成单流
    // cloudMixerCfg.audioFileCfg = CloudMixerAudioFileCfg.single(
    //   svrPath: dir,
    //   svrFileNameSuffix: '.mp3',
    //   subscribeAudios: ["_cr_all_"],
    // );
    // cloudMixerCfg.videoFileCfg = CloudMixerVideoFileCfg.single(
    //   svrPath: dir,
    //   svrFileNameSuffix: '.mp4',
    //   subscribeVideos: ["_cr_all_"], // ["_cr_allDefCam_"]
    //   aStreamType: 1,
    // );
    // 开始录制
    mixerId = await RtcSDK.recordManager.createCloudMixer(cloudMixerCfg);
  }

  updateCloudMixerContent() {
    if (isRecord.value) {
      // 更新混图器内容时，只能更新内容和布局，不能更改混图器规格、输出目标；
      cloudMixerCfg.videoFileCfg?.layoutConfig = getMutiMixerContent();
      RtcSDK.recordManager.updateCloudMixerContent(mixerId!, cloudMixerCfg);
    }
  }

  destroyCloudMixer() {
    RtcSDK.recordManager.destroyCloudMixer(mixerId!);
    mixerId = null;
  }
}
