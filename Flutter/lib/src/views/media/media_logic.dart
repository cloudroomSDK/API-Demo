import 'dart:async';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rtcsdk_demo/src/controller/app_controller.dart';
import 'package:rtcsdk_demo/src/controller/permission_controller.dart';
import 'package:rtcsdk_demo/src/controller/rtc_controller.dart';
import 'package:rtcsdk_demo/src/models/media_notify.dart';
import 'package:rtcsdk_demo/src/routes/navigator.dart';
import 'package:rtcsdk_demo/src/utils/logger_util.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:rtcsdk/rtcsdk.dart';

class MediaLogic extends GetxController {
  final appLogic = Get.find<AppController>();
  final rtcLogic = Get.find<RTCController>();
  final permissionLogic = Get.find<PermissionController>();
  final String confId = Get.arguments['confId'];

  final bool playLocRecordFile = false; // 是否播放本地录制文件
  Rx<MEDIA_STATE> mediaState = MEDIA_STATE.MEDIA_STOP.obs;
  bool get isPlay => (mediaState.value != MEDIA_STATE.MEDIA_STOP);
  RxBool isShowBtn = false.obs;
  String filePath = '';
  Rx<String> fileName = ''.obs;
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

  initEvt() {
    subs.addAll([
      rtcLogic.onNotifyMediaOpened.listen(notifyMediaOpened),
      rtcLogic.onNotifyMediaStart.listen(notifyMediaStart),
      rtcLogic.onNotifyMediaPause.listen(notifyMediaPause),
      rtcLogic.onNotifyMediaStop.listen(notifyMediaStop),
    ]);

    getMediaInfo();
    setMediaCfg();
  }

  getMediaInfo() async {
    MediaInfo mediaInfo = await RtcSDK.mediaManager.getMediaInfo();
    mediaState.value = mediaInfo.state;
  }

  setMediaCfg() {
    VideoCfg cfg = VideoCfg(
      size: VSize(width: 360, height: 640),
      fps: 20,
    );
    // VideoCfg.Cfg_360..rotate()..fps = 20;
    RtcSDK.mediaManager.setMediaCfg(cfg);
  }

  // 开启影音共享
  void startPlayMedia() {
    if (playLocRecordFile) {
      RtcSDK.recordManager.playbackRecordFile(filePath);
    } else {
      RtcSDK.mediaManager.startPlayMedia(filePath);
    }
  }

  // 暂停影音共享
  void pausePlayMedia(bool pause) {
    RtcSDK.mediaManager.pausePlayMedia(pause);
  }

  // 停止影音共享
  void stopPlayMedia() {
    RtcSDK.mediaManager.stopPlayMedia();
  }

  void switchPlay() {
    if (!isPlay) {
      startPlayMedia();
    } else {
      stopPlayMedia();
    }
  }

  notifyMediaOpened(MediaFileInfo mediaFileInfo) {
    print(mediaFileInfo.toJson().toString());
  }

  notifyMediaStart(MediaNotify mediaNotify) {
    mediaState.value = MEDIA_STATE.MEDIA_START;
  }

  notifyMediaPause(MediaNotify mediaNotify) {
    mediaState.value =
        mediaNotify.pause! ? MEDIA_STATE.MEDIA_PAUSE : MEDIA_STATE.MEDIA_START;
  }

  notifyMediaStop(MediaNotify mediaNotify) {
    mediaState.value = MEDIA_STATE.MEDIA_STOP;
    switch (mediaNotify.reason) {
      case MEDIA_STOP_REASON.MEDIA_CLOSE:
        EasyLoading.showToast('文件关闭');
        break;
      case MEDIA_STOP_REASON.MEDIA_FINI:
        EasyLoading.showToast('播放到文件尾部');
        break;
      case MEDIA_STOP_REASON.MEDIAMEDIA_FILEOPEN_ERR_STOP:
        EasyLoading.showToast('打开文件失败');
        break;
      case MEDIA_STOP_REASON.MEDIA_FORMAT_ERR:
        EasyLoading.showToast('文件格式错误');
        break;
      case MEDIA_STOP_REASON.MEDIA_UNSUPPORT:
        EasyLoading.showToast('影音格式不支持');
        break;
      case MEDIA_STOP_REASON.MEDIA_EXCEPTION:
        EasyLoading.showToast('其他异常');
        break;
      default:
    }
  }

  // getAllFilesInMediaPath() async {
  //   List<String> files = await RtcSDK.mediaManager.getAllFilesInMediaPath();
  //   Logger.log('files: $files');
  // }

  // 选本地录制文件
  selRecordFile() async {
    dynamic dfile = await AppNavigator.toSelLocRecord(confId: confId);
    if (dfile != null) {
      RecordFileShow file = dfile as RecordFileShow;
      filePath = file.fileName;
      fileName.value = file.fileName;
    }
  }

  // 选文件
  filePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mov', 'rmvb', 'rm', 'flv', '3gp'],
    );
    if (result != null) {
      PlatformFile file = result.files.first;
      filePath = file.path!;
      fileName.value = file.name;
      Logger.log('filePath: $filePath, fileName: ${file.name}');
    }
  }

  // 选文件
  pickFile() async {
    permissionLogic.storage(() async {
      if (playLocRecordFile) {
        selRecordFile();
      } else {
        filePicker();
      }
    }, () {
      EasyLoading.showToast('请打开存储权限');
    });
  }

  Timer? _pauseBtnTimer;
  showHandleBtn() {
    if (mediaState.value == MEDIA_STATE.MEDIA_START) {
      isShowBtn.value = true;
      _pauseBtnTimer?.cancel();
      _pauseBtnTimer = Timer(const Duration(seconds: 4), () {
        _pauseBtnTimer = null;
        isShowBtn.value = false;
      });
    }
  }
}
