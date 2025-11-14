// ignore_for_file: avoid_renaming_method_parameters, no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:rtcsdk_demo/src/controller/permission_controller.dart';
import 'package:rtcsdk_demo/src/models/app_config.dart';
import 'package:rtcsdk_demo/src/models/audio_status_changed.dart';
import 'package:rtcsdk_demo/src/models/change_nickname.dart';
import 'package:rtcsdk_demo/src/models/cloud_mixer_state.dart';
import 'package:rtcsdk_demo/src/models/custom_msg.dart';
import 'package:rtcsdk_demo/src/models/error_def.dart';
import 'package:rtcsdk_demo/src/models/loc_mixer_output_info.dart';
import 'package:rtcsdk_demo/src/models/media_notify.dart';
import 'package:rtcsdk_demo/src/models/mic_energy.dart';
import 'package:rtcsdk_demo/src/models/record_file_state.dart';
import 'package:rtcsdk_demo/src/models/video_status_changed.dart';
import 'package:rtcsdk_demo/src/routes/navigator.dart';
import 'package:rtcsdk_demo/src/utils/logger_util.dart';
import 'package:rtcsdk_demo/src/utils/store.dart';
import 'package:rtcsdk_demo/src/utils/utils.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:rtcsdk/rtcsdk.dart';
import 'package:rtcsdk_demo/src/widgets/loading_view.dart';
import 'package:rxdart/rxdart.dart' hide Rx;
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class RTCController extends GetxController {
  final permissionLogic = Get.find<PermissionController>();

  String nickName = '';
  String? _userID;
  int? _confID;
  List<CameraInfo> myCamerasInfo = [];

  String get userID => '$_userID';
  String get confID => _confID != null ? '$_confID' : '';
  UsrVideoId get selfUsrVideoId => UsrVideoId(userId: userID, videoID: -1);

  RxBool isLogined = false.obs;
  RxBool isOpenMyMic = false.obs;
  RxBool isOpenMySpeaker = false.obs;
  RxBool isOpenMyCamera = false.obs;
  Rx<CAMERA_POSITION> myCameraPosition = CAMERA_POSITION.FRONT.obs;
  Rx<AudioCfg>? audioCfg;
  StreamSubscription<ConnectivityResult>? connectivityResultSub;

  @override
  void onInit() {
    _confID = RTCStorage.getConfID();
    String? _nickName = RTCStorage.getNickName();
    if (_nickName == null) {
      nickName =
          "${Platform.isAndroid ? "Android" : "IOS"}_${Utils.getRandom()}";
      RTCStorage.setNickName(nickName);
    } else {
      nickName = _nickName;
    }
    _userID ??= nickName;
    getVersion();
    sdkInit();
    super.onInit();
  }

  getVersion() async {
    String ver = await RtcSDK.sdkManager.getVersion();
    Logger.log('native sdk version: $ver');
  }

  sdkInit() async {
    RtcSDK.roomManager.setListener(RoomListener(
      onUserEnterMeeting: userEnterMeeting,
      onUserLeftMeeting: userLeftMeeting,
      onMeetingDropped: meetingDropped,
      onMeetingStopped: meetingStopped,
      onNetStateChanged: netStateChanged,
      onNotifyMeetingCustomMsg: notifyMeetingCustomMsg,
    ));
    RtcSDK.audioManager.setListener(AudioListener(
      onAudioStatusChanged: audioStatusChanged,
      onAudioDevChanged: audioDevChanged,
      onMicEnergyUpdate: micEnergyUpdate,
    ));
    RtcSDK.videoManager.setListener(VideoListener(
      onVideoStatusChanged: videoStatusChanged,
      onVideoDevChanged: videoDevChanged,
    ));
    RtcSDK.memberManager.setListener(MemberListener(
      onNotifyNickNameChanged: notifyNickNameChanged,
    ));
    RtcSDK.screenShareManager.setListener(ScreenShareListener(
      onNotifyScreenShareStarted: notifyScreenShareStarted,
      onNotifyScreenShareStopped: notifyScreenShareStopped,
      onNotifyScreenMarkStarted: notifyScreenMarkStarted,
      onNotifyScreenMarkStopped: notifyScreenMarkStopped,
    ));
    RtcSDK.recordManager.setListener(RecordListener(
      onLocMixerOutputInfo: locMixerOutputInfo,
      onLocMixerStateChanged: locMixerStateChanged,
      onNotifyRecordFileStateChanged: notifyRecordFileStateChanged,
      onNotifyRecordFileUploadProgress: notifyRecordFileUploadProgress,
      onCreateCloudMixerFailed: createCloudMixerFailed, // 启动云端录制、云端直播失败通知
      onCloudMixerStateChanged: cloudMixerStateChanged, // 云端录制、云端直播状态变化通知
      onCloudMixerInfoChanged: cloudMixerInfoChanged, // 云端录制、云端直播配置变化通知
      onCloudMixerOutputInfoChanged:
          cloudMixerOutputInfoChanged, // 云端录制文件、云端直播输出变化通知
    ));
    RtcSDK.mediaManager.setListener(MediaListener(
      onNotifyMediaOpened: notifyMediaOpened,
      onNotifyMediaStart: notifyMediaStart,
      onNotifyMediaPause: notifyMediaPause,
      onNotifyMediaStop: notifyMediaStop,
    ));
    // RtcSDK.inviteManager.setListener(InviteListener(
    //   onNotifyInviteIn: notifyInviteIn,
    //   onNotifyInviteAccepted: notifyInviteAccept,
    //   onNotifyInviteRejected: notifyInviteReject,
    //   onNotifyInviteCanceled: notifyInviteCancel,
    // ));
    SdkInitDat sdkInitDat = SdkInitDat(
      sdkDatSavePath: "${(await Utils.storeDirectory())}/",
      noCall: false, // 需要用到呼叫模块，则传false
      noQueue: false, // 需要用到队列模块，则传false
    );
    RtcSDK.sdkManager.setChannelListener((String method, dynamic arguments) {
      Logger.log('主调: $method, 参数: $arguments');
    });
    RtcSDK.sdkManager.setCallbackListener((String method, dynamic arguments) {
      if (method == 'micEnergyUpdate' || method == 'netStateChanged') return;
      Logger.log('通知: $method, 参数: $arguments');
    });
    final sdkErr = await RtcSDK.sdkManager.init(
        sdkInitDat,
        SDKListener(
          onLineOff: lineOff,
        ));
    if (sdkErr == 0) {
      AppConfig? appConfig = RTCStorage.getAppConfig();
      if (appConfig != null) await setServerAddr(appConfig.serverAddr);
      await login();
      initConnectivity();
    }
  }

  setServerAddr(String serverAddr) async {
    await RtcSDK.sdkManager.setServerAddr(serverAddr);
  }

  initConnectivity() async {
    connectivityResultSub ??= Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      Logger.log('connectivityResult by listener: $result');
      // ConnectivityResult.ethernet 以太网
      // ConnectivityResult.vpn
      // ConnectivityResult.bluetooth
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        if (isLogined.value == false) {
          login();
        }
      } else if (result == ConnectivityResult.none) {
        Logger.log('网络连接失败，请检查网络！');
      }
    });
  }

  Future<void> login() async {
    LoadingView.singleton.wrap(
        text: '登录中...',
        asyncFunction: () async {
          AppConfig appConfig = RTCStorage.getAppConfig()!;
          String appSecret =
              md5.convert(utf8.encode(appConfig.appSecret)).toString();
          Logger.log("appConfig: ${appConfig.toJson()}");
          LoginDat config = LoginDat(
              privAcnt: nickName, //'uid_$nickName', // userID, 唯一标识
              // nickName: nickName,
              appID: appConfig.appId,
              appSecret: appSecret);
          LoginResult result = await RtcSDK.sdkManager.login(config);
          Logger.log("LoginResult: ${result.toJson()}");
          try {
            isLogined.value = result.sdkErr == 0;
            if (result.sdkErr == 0) {
              // 登录成功
              _userID = result.userID;
              EasyLoading.showToast("登录成功: $_userID");
            } else if (result.sdkErr == 9) {
              reLogin();
            } else if (result.sdkErr == 202) {
              // 服务器没响应
              Future.delayed(const Duration(seconds: 3), login);
            } else if (result.sdkErr == 205) {
              // 网络超时 205
              EasyLoading.showToast(
                  '${ErrorDef.getMessage(result.sdkErr)} 10秒后重新登录');
              Future.delayed(const Duration(seconds: 10), reLogin);
            } else {
              // 登录失败
              EasyLoading.showToast(ErrorDef.getMessage(result.sdkErr));
            }
          } catch (e) {
            Logger.log("LoginResult: $e");
          }
        });
  }

  logout() async {
    isLogined.value = false;
    await RtcSDK.sdkManager.logout();
  }

  // 主要用来处理开发时shift+R刷新导致的问题
  reLogin() async {
    await logout();
    await login();
  }

  Future<int> enterMeeting(int id) async {
    int sdkErr = await RtcSDK.roomManager.enterMeeting(id, nickName);
    Logger.log('enterMeeting sdkErr: $sdkErr');
    if (sdkErr == 0) {
      _confID = id;
      RTCStorage.setConfID(id);
      WakelockPlus.enable();
    } else {
      EasyLoading.showToast(ErrorDef.getMessage(sdkErr));
    }
    onEnterRoom.sink.add(sdkErr);
    return sdkErr;
  }

  Future<void> exitMeeting() async {
    await RtcSDK.roomManager.exitMeeting();
    closeMic();
    setSpeakerOut(false);
    closeCamera();
    WakelockPlus.disable();
  }

  // 默认音频状态
  defaultAppAudio() async {}

  // 根据当前各个cfg恢复音频状态
  resetAppAudio() async {}

  // 默认视频状态
  defaultAppVideo() async {}

  // 根据当前各个cfg恢复视频状态
  resetAppVideo() async {}

  Future<AudioCfg> getAudioCfg() async {
    AudioCfg cfg = await RtcSDK.audioManager.getAudioCfg();
    Logger.logPrint('AudioCfg: ${cfg.toJson()}');
    return cfg;
  }

  setAudioCfg(AudioCfg cfg) async {
    await RtcSDK.audioManager.setAudioCfg(cfg);
  }

  openMic() async {
    await permissionLogic.microphone(() async {
      RtcSDK.audioManager.openMic(userID);
      isOpenMyMic.value = true;
    }, () {
      EasyLoading.showToast('请打开麦克风权限');
    });
  }

  closeMic() async {
    RtcSDK.audioManager.closeMic(userID);
    isOpenMyMic.value = false;
  }

  switchMic() async {
    bool isOpen = !isOpenMyMic.value;
    isOpen ? openMic() : closeMic();
  }

  getSpeakerOut() async {
    isOpenMySpeaker.value = await RtcSDK.audioManager.getSpeakerOut();
  }

  setSpeakerOut(bool speakerOut) async {
    await RtcSDK.audioManager.setSpeakerOut(speakerOut);
    isOpenMySpeaker.value = speakerOut;
  }

  switchSpeakerOut() async {
    bool isSpeakerOut = !isOpenMySpeaker.value;
    await setSpeakerOut(isSpeakerOut);
    isOpenMySpeaker.value = isSpeakerOut;
  }

  openCamera() async {
    await permissionLogic.camera(() async {
      RtcSDK.videoManager.openVideo(userID);
      isOpenMyCamera.value = true;
    }, () {
      EasyLoading.showToast('请打开摄像头权限');
    });
  }

  closeCamera() async {
    RtcSDK.videoManager.closeVideo(userID);
    isOpenMyCamera.value = false;
  }

  switchCamera() async {
    bool _isOpenCamera = !isOpenMyCamera.value;
    _isOpenCamera ? openCamera() : closeCamera();
  }

  // 获取用户所有的摄像头信息
  Future<List<CameraInfo>> getAllVideoInfo(String uid) async {
    return await RtcSDK.videoManager.getAllVideoInfo(uid);
  }

  // 获取用户默认摄像头
  getDefaultVideo() async {
    if (myCamerasInfo.isEmpty) {
      myCamerasInfo = await getAllVideoInfo(userID);
    }
    int videoID = await RtcSDK.videoManager.getDefaultVideo(userID);

    CameraInfo? cInfo = myCamerasInfo
        .firstWhereOrNull((CameraInfo cInfo) => cInfo.videoID == videoID);

    if (cInfo != null) {
      myCameraPosition.value = cInfo.position;
    }
  }

  // 设置用户默认摄像头 (切换前后摄像头)
  setDefaultVideo(CAMERA_POSITION cameraPosition) async {
    if (myCamerasInfo.isEmpty) {
      myCamerasInfo = await getAllVideoInfo(userID);
    }

    CameraInfo? cInfo = myCamerasInfo.firstWhereOrNull(
        (CameraInfo cInfo) => cInfo.position == cameraPosition);

    if (cInfo != null) {
      RtcSDK.videoManager.setDefaultVideo(userID, cInfo.videoID);
      myCameraPosition.value = cameraPosition;
    }
  }

  switchDefaultVideo() async {
    setDefaultVideo(myCameraPosition.value == CAMERA_POSITION.BACK
        ? CAMERA_POSITION.FRONT
        : CAMERA_POSITION.BACK);
  }

  PublishSubject<int> onEnterRoom = PublishSubject<int>();
  PublishSubject<int> onLineOff = PublishSubject<int>();
  PublishSubject<String> onUserEnterMeeting = PublishSubject<String>();
  PublishSubject<String> onUserLeftMeeting = PublishSubject<String>();
  PublishSubject<void> onMeetingStopped = PublishSubject<void>();
  PublishSubject<int> onNetStateChanged = PublishSubject<int>();
  PublishSubject<ChangeNickName> onNotifyNickNameChanged =
      PublishSubject<ChangeNickName>();

  PublishSubject<MicEnergy> onMicEnergyUpdate = PublishSubject<MicEnergy>();
  PublishSubject<AudioStatusChanged> onAudioStatusChanged =
      PublishSubject<AudioStatusChanged>();
  PublishSubject<void> onAudioDevChanged = PublishSubject<void>();
  PublishSubject<VideoStatusChanged> onVideoStatusChanged =
      PublishSubject<VideoStatusChanged>();
  PublishSubject<String> onVideoDevChanged = PublishSubject<String>();

  // 屏幕共享
  PublishSubject<void> onNotifyScreenShareStarted = PublishSubject<void>();
  PublishSubject<void> onNotifyScreenShareStopped = PublishSubject<void>();
  PublishSubject<void> onNotifyScreenMarkStarted = PublishSubject<void>();
  PublishSubject<void> onNotifyScreenMarkStopped = PublishSubject<void>();

  // 本地录制
  PublishSubject<LocMixerState> onLocMixerStateChanged =
      PublishSubject<LocMixerState>();
  PublishSubject<LocMixerOutputInfo> onLocMixerOutputInfo =
      PublishSubject<LocMixerOutputInfo>();
  PublishSubject<RecordFileState> onNotifyRecordFileStateChanged =
      PublishSubject<RecordFileState>();

  // 云端录制
  PublishSubject<String> onCreateCloudMixerFailed = PublishSubject<String>();
  PublishSubject<CloudMixerState> onCloudMixerStateChanged =
      PublishSubject<CloudMixerState>();
  PublishSubject<String> onCloudMixerInfoChanged = PublishSubject<String>();
  PublishSubject<CloudMixerOutputInfo> onCloudMixerOutputInfoChanged =
      PublishSubject<CloudMixerOutputInfo>();

  // 影音
  PublishSubject<MediaFileInfo> onNotifyMediaOpened =
      PublishSubject<MediaFileInfo>();
  PublishSubject<MediaNotify> onNotifyMediaStart =
      PublishSubject<MediaNotify>();
  PublishSubject<MediaNotify> onNotifyMediaPause =
      PublishSubject<MediaNotify>();
  PublishSubject<MediaNotify> onNotifyMediaStop = PublishSubject<MediaNotify>();

  // 房间内消息
  PublishSubject<CustomMsg> onNotifyMeetingCustomMsg =
      PublishSubject<CustomMsg>();

  @override
  void onClose() async {
    onEnterRoom.close();
    onLineOff.close();
    onUserEnterMeeting.close();
    onUserLeftMeeting.close();
    onMeetingStopped.close();
    onNetStateChanged.close();
    onNotifyNickNameChanged.close();
    // 音频
    onMicEnergyUpdate.close();
    onAudioStatusChanged.close();
    onAudioDevChanged.close();
    // 视频
    onVideoStatusChanged.close();
    onVideoDevChanged.close();
    // 屏幕共享
    onNotifyScreenShareStarted.close();
    onNotifyScreenShareStopped.close();
    onNotifyScreenMarkStarted.close();
    onNotifyScreenMarkStopped.close();
    // 本地录制
    onLocMixerOutputInfo.close();
    onLocMixerStateChanged.close();
    onNotifyRecordFileStateChanged.close();
    // 云端录制
    onCreateCloudMixerFailed.close();
    onCloudMixerStateChanged.close();
    onCloudMixerInfoChanged.close();
    onCloudMixerOutputInfoChanged.close();
    // 房间内消息
    onNotifyMeetingCustomMsg.close();

    connectivityResultSub?.cancel();
    super.onClose();
  }

  // 通知用户掉线
  void lineOff(int sdkErr) async {
    onLineOff.sink.add(sdkErr);
    isLogined.value = false;
    EasyLoading.showToast('掉线中...');
  }

  // 某用户进入了房间
  void userEnterMeeting(String userID) {
    EasyLoading.showToast('$userID 进入了房间');
    onUserEnterMeeting.sink.add(userID);
  }

  // 某用户离开了房间
  void userLeftMeeting(String userID) {
    EasyLoading.showToast('$userID 离开了房间');
    onUserLeftMeeting.sink.add(userID);
  }

  // 房间已被结束
  void meetingStopped() {
    EasyLoading.showToast('房间已被结束');
    AppNavigator.backMain();
  }

  // 通知从房间里掉线了
  void meetingDropped(MEETING_DROPPED_REASON reason) {
    if (reason == MEETING_DROPPED_REASON.CRVIDEOSDK_DROPPED_TIMEOUT) {
      EasyLoading.showToast('网络通信超时');
    } else {
      if (reason == MEETING_DROPPED_REASON.CRVIDEOSDK_DROPPED_KICKOUT) {
        EasyLoading.showToast('您已被请出房间');
      } else if (reason ==
          MEETING_DROPPED_REASON.CRVIDEOSDK_DROPPED_BALANCELESS) {
        EasyLoading.showToast('余额不足');
      } else if (reason ==
          MEETING_DROPPED_REASON.CRVIDEOSDK_DROPPED_TOKENINVALID) {
        EasyLoading.showToast('token过期');
      }
      AppNavigator.backMain();
    }
  }

  // 网络变化通知
  void netStateChanged(int level) {
    EasyLoading.showToast('网络变化: $level');
  }

  // 通知用户修改昵称
  void notifyNickNameChanged(String userId, String oldName, String newName) {
    RTCStorage.setNickName(newName);
    onNotifyNickNameChanged.sink.add(
        ChangeNickName(userId: userId, newName: newName, oldName: oldName));
  }

  void micEnergyUpdate(String userId, int newLevel, int oldLevel) {
    onMicEnergyUpdate.sink.add(MicEnergy(
      userId: userId,
      newLevel: newLevel,
      oldLevel: oldLevel,
    ));
  }

  void audioStatusChanged(
    String userId,
    ASTATUS newStatus,
    ASTATUS oldStatus,
  ) {
    Logger.log('audioStatusChanged: $userId __ $newStatus __ $oldStatus');
    isOpenMyMic.value = newStatus == ASTATUS.AOPEN;
    onAudioStatusChanged.sink.add(AudioStatusChanged(
      userId: userId,
      oldStatus: oldStatus,
      newStatus: newStatus,
    ));
  }

  void audioDevChanged() {
    Logger.log('audioDevChanged');
    onAudioDevChanged.sink.add(null);
  }

  void videoStatusChanged(
    String userId,
    VSTATUS newStatus,
    VSTATUS oldStatus,
  ) {
    Logger.log('videoStatusChanged: $userId  __ $newStatus __ $oldStatus ');
    isOpenMyCamera.value = newStatus == VSTATUS.VOPEN;
    onVideoStatusChanged.sink.add(VideoStatusChanged(
      userId: userId,
      oldStatus: oldStatus,
      newStatus: newStatus,
    ));
  }

  void videoDevChanged(String userID) {
    Logger.log('videoDevChanged $userID');
    onVideoDevChanged.sink.add(userID);
  }

  // 通知开启屏幕共享
  void notifyScreenShareStarted(String sharerID) {
    onNotifyScreenShareStarted.sink.add(null);
  }

  // 通知停止屏幕共享
  void notifyScreenShareStopped(String oprUserID) {
    onNotifyScreenShareStopped.sink.add(null);
  }

  // 通知开启屏幕共享标注
  void notifyScreenMarkStarted() {
    onNotifyScreenMarkStarted.sink.add(null);
  }

  // 通知停止屏幕共享标注
  void notifyScreenMarkStopped() {
    onNotifyScreenMarkStopped.sink.add(null);
  }

  // 本地录制文件、本地直播信息通知
  void locMixerOutputInfo(
      String mixerID, String nameOrUrl, MixerOutputInfo mixerOutputInfo) {
    onLocMixerOutputInfo.sink.add(LocMixerOutputInfo(
      mixerID: mixerID,
      nameOrUrl: nameOrUrl,
      mixerOutputInfo: mixerOutputInfo,
    ));
  }

  // 本地混图器状态变化通知
  void locMixerStateChanged(LocMixerState crLocMixerState) {
    onLocMixerStateChanged.sink.add(crLocMixerState);
  }

  void notifyRecordFileStateChanged(String fileName, RECORD_FILE_STATE state) {
    onNotifyRecordFileStateChanged.sink.add(RecordFileState(fileName, state));
  }

  void notifyRecordFileUploadProgress(String fileName, int percent) {}

  // 启动云端录制、云端直播失败通知
  void createCloudMixerFailed(String mixerID, int sdkErr) {
    onCreateCloudMixerFailed.sink.add(mixerID);
  }

  // 云端录制、云端直播状态变化通知
  // 开启云端混图器后，房间内所有人都将收到cloudMixerStateChanged通知进入MIXER_STARTING（启动中状态）
  void cloudMixerStateChanged(
      String mixerID, String operatorID, MIXER_STATE state, String exParam) {
    onCloudMixerStateChanged.sink.add(CloudMixerState(
      mixerID: mixerID,
      operatorID: operatorID,
      state: state,
      exParam: exParam,
    ));
  }

  // 云端录制、云端直播配置变化通知
  // 可调用：getCloudMixerInfo获取相关信息
  void cloudMixerInfoChanged(String mixerID) {
    onCloudMixerInfoChanged.sink.add(mixerID);
  }

  // 云端录制文件、云端直播输出变化通知
  void cloudMixerOutputInfoChanged(
      String mixerID, CloudMixerOutputInfo cloudMixerOutputInfo) {
    onCloudMixerOutputInfoChanged.sink.add(cloudMixerOutputInfo);
  }

  // 通知影音文件打开
  void notifyMediaOpened(MediaFileInfo mediaFileInfo) {
    onNotifyMediaOpened.sink.add(mediaFileInfo);
  }

  // 通知影音开始播放
  void notifyMediaStart(String userID) {
    onNotifyMediaStart.sink.add(MediaNotify(userID: userID));
  }

  // 通知影音是否暂停播放
  void notifyMediaPause(String userID, bool pause) {
    onNotifyMediaPause.sink.add(MediaNotify(userID: userID, pause: pause));
  }

  // 通知影音播放停止
  void notifyMediaStop(String userID, MEDIA_STOP_REASON reason) {
    onNotifyMediaStop.sink.add(MediaNotify(userID: userID, reason: reason));
  }

  // 房间内消息通知
  void notifyMeetingCustomMsg(String fromUserID, String text) {
    onNotifyMeetingCustomMsg.sink.add(CustomMsg(fromUserID, text));
  }
}
