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

class SelectItemMode<T> {
  String label;
  T value;

  SelectItemMode(this.label, this.value);
}

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
  Rx<VideoRatio> get ratio => vratio[ratioidx.value].obs;
  List<VideoPosition> vps = [];
  RxList<UsrVideoId> uvids = <UsrVideoId>[].obs;
  List<StreamSubscription> subs = [];

  VideoCfg? _cfg;
  VideoEffects? _effect;
  VideoAttributes? _videoAttributes;
  RxDouble kbps = 0.0.obs;
  RxDouble fps = 15.0.obs;
  RxInt ratioidx = 0.obs;
  RxBool moreFunc = false.obs;
  RxBool denoise = false.obs; // 视频降噪
  RxBool upsideDown = false.obs; // 视频上下翻转
  List<SelectItemMode<int>> mirrors = [
    SelectItemMode('自动', -1),
    SelectItemMode('关', 0),
    SelectItemMode('开', 1)
  ];
  RxInt mirror = (-1).obs; // 视频左右镜像(-1：自动，0：关，1：开)
  RxString get mirrorLabal =>
      (mirrors.firstWhere((m) => m.value == mirror.value).label).obs;

  List<SelectItemMode<int>> degrees = [
    SelectItemMode('自动', -1),
    SelectItemMode('0度', 0),
    SelectItemMode('90度', 90),
    SelectItemMode('180度', 180),
    SelectItemMode('270度', 270),
  ];
  RxInt degree = 90.obs; // 视频旋转（-1：自动，0-270：旋转角度）
  RxString get degreeLabal =>
      (degrees.firstWhere((m) => m.value == degree.value).label).obs;

  List<SelectItemMode<int>> sizes = [
    SelectItemMode('不设置', 0),
    SelectItemMode('256P', 256),
    SelectItemMode('360P', 360),
    SelectItemMode('480P', 480),
  ];
  Rx<SelectItemMode> sizeValue = SelectItemMode('不设置', 0).obs;

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
    switchRatio(0);
    Function watchableVideos = Utils.debounce(getWatchableVideos);
    subs.addAll([
      rtcLogic.onEnterRoom.listen((sdkErr) async {
        if (sdkErr == 0) {
          _effect ??= await RtcSDK.videoManager.getVideoEffects();
          denoise.value = _effect!.denoise;
          upsideDown.value = _effect!.upsideDown;
          mirror.value = _effect!.mirror;
          degree.value = _effect!.degree;
          // _effect: {denoise: false, upsideDown: false, mirror: -1, degree: -1}

          _videoAttributes ??= await RtcSDK.videoManager
              .getLocVideoAttributes(rtcLogic.selfUsrVideoId.videoID);
          if (_videoAttributes!.quality2Cfg != null) {
            sizeValue.value = sizes.firstWhere(
                (s) => s.value == _videoAttributes!.quality2Cfg!.size.height);
          }
        }
      }),
      rtcLogic.onAudioDevChanged.listen((_) {
        if (!rtcLogic.isOpenMyMic.value) {
          rtcLogic.openMic();
          rtcLogic.setSpeakerOut(true);
        }
      }),
      rtcLogic.onVideoStatusChanged.listen((VideoStatusChanged vsc) {
        if (vsc.userId != rtcLogic.userID &&
            (vsc.newStatus == VSTATUS.VOPEN ||
                vsc.newStatus == VSTATUS.VCLOSE)) {
          watchableVideos();
        }
      }),
      rtcLogic.onVideoDevChanged.listen((String userID) {
        if (userID == rtcLogic.userID && !rtcLogic.isOpenMyCamera.value) {
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

  // changedDeg(double val) {
  //   degree.value = val;
  // }

  setEffect() {
    _effect!.degree = degree.value.toInt();
    _effect!.denoise = denoise.value;
    _effect!.mirror = mirror.value;
    _effect!.upsideDown = upsideDown.value;
    RtcSDK.videoManager.setVideoEffects(_effect!);
  }

  // changedDegEnd(double val) {
  //   setEffect();
  // }

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

  void showMoreFunc() {
    moreFunc.value = !moreFunc.value;
  }

  void onMyViewId(int viewID) {
    // 打开摄像头之后绘制上去了才有图像
    Future.delayed(const Duration(seconds: 5)).then((value) {
      // RtcSDK.videoManager.isPicEmpty(viewID).then((bool isPicEmpty) {
      //   Logger.log('有图像才能获取Pic, isPicEmpty: $isPicEmpty');
      //   if (isPicEmpty) return;
      //   RtcSDK.videoManager.getShowPic(viewID).then((Uint8List val) {
      //     Logger.log('Pic: $val');
      //   }).catchError((e) {
      //     Logger.log('Pic err: $e');
      //   });

      //   // 获取当前图像帧的显示时间戳
      //   RtcSDK.videoManager.getPicFrameTime(viewID).then((int timestamp) {
      //     Logger.log('timestamp: $timestamp');
      //   });

      //   RtcSDK.videoManager.getPicWidth(viewID).then((int width) {
      //     Logger.log('pic width: $width');
      //   });
      //   RtcSDK.videoManager.getPicHeight(viewID).then((int height) {
      //     Logger.log('pic height: $height');
      //   });
      // });

      // // 获取视频显示模式
      // RtcSDK.videoManager.getScaleType(viewID).then((int scaleType) {
      //   Logger.log('scaleType: $scaleType');
      //   // RtcSDK.videoManager.setScaleType(viewID, 1);
      // });
    });
  }

  setLocVideoAttributes(size) async {
    _videoAttributes ??= await RtcSDK.videoManager
        .getLocVideoAttributes(rtcLogic.selfUsrVideoId.videoID);
    // 不配置，使用全局变量 videoCfg, 即用setVideoCfg可以改
    // 配置过了只能用setLocVideoAttributes来改
    // _videoAttributes!.quality1Cfg = null;
    if (size == null || size == 0) {
      sizeValue.value = sizes[0];
      _videoAttributes!.quality2Cfg = null;
    } else {
      sizeValue.value = sizes.firstWhere((s) => s.value == size);
      VideoCfg cfg = size == 256
          ? VideoCfg.Cfg_256
          : size == 360
              ? VideoCfg.Cfg_360
              : VideoCfg.Cfg_480;
      // cfg.size.rotate();
      _videoAttributes!.quality2Cfg = cfg;
    }
    await RtcSDK.videoManager.setLocVideoAttributes(
        rtcLogic.selfUsrVideoId.videoID, _videoAttributes!);
  }

  toMembers() {
    AppNavigator.toMembers();
  }
}
