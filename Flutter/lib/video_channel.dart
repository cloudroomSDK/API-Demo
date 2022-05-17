import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'application/application.dart';
import 'package:cloudroomvideosdk/cloudroomvideosdk.dart';
import 'component/video_views.dart';
import 'application/common_func.dart';

class VideoChannel extends StatefulWidget {
  const VideoChannel({Key? key}) : super(key: key);

  @override
  _VideoChannelState createState() => _VideoChannelState();
}

GlobalKey<VideoViewsState> videoViewsKey = GlobalKey();

class _VideoChannelState extends State<VideoChannel>
    with CrSDKNotifier, CommonFunc {
  String userId = GlobalConfig.instance.userID;
  int? confId = GlobalConfig.instance.confID;
  String nickName = GlobalConfig.instance.nickName;
  bool _isOpenCamera = false; // 是否开启摄像头
  bool _isOpenMic = false; // 是否开启麦克风
  bool _isSpeakerOut = false; // 是否外放（扬声器）
  VideoViews? _videoViews;

  bool _isFrontCamera = true; // 是否前置摄像头

  @override
  void initState() {
    addCrNotifierListener([
      NOTIFIER_EVENT.lineOff,
      NOTIFIER_EVENT.meetingDropped,
      NOTIFIER_EVENT.videoStatusChanged,
      NOTIFIER_EVENT.audioStatusChanged,
    ]);
    initPage(confId);
    super.initState();
  }

  @override
  void dispose() {
    disposeCrNotifierListener();
    CrSDK.instance.exitMeeting();
    CrSDK.instance.logout();
    super.dispose();
  }

  @override
  enterMeetingSuccess() {
    switchMicPhone(true);
    setSpeakerOut(true);
    switchCamera(true);
    _videoViews = VideoViews(
        key: videoViewsKey,
        updateDefaultCameraInfoCallback: updateDefaultCameraInfoCallback);
  }

  @override
  lineOff(int sdkErr) {
    toHomePage();
  }

  @override
  meetingDropped(CR_MEETING_DROPPED_REASON reason) {
    commonMeetingDropped(reason);
  }

  @override
  toHomePage() {
    Duration transitionDuration = const Duration(milliseconds: 0);
    Application.router.navigateTo(context, "/",
        replace: true,
        transitionDuration: transitionDuration,
        clearStack: true);
  }

  // 监听视像头状态
  @override
  videoStatusChanged(CrVideoStatusChanged vsc) {
    if (vsc.userId == userId) {
      setState(() => _isOpenCamera = vsc.newStatus == CR_VSTATUS.VOPEN);
    }
  }

  updateDefaultCameraInfoCallback(CrCameraInfo cameraInfo) {
    setState(() {
      _isFrontCamera = (cameraInfo.cameraPosition == CR_CAMERA_POSITION.FRONT);
    });
  }

  // 摄像头开关
  void switchCamera(bool isOpenCamera) {
    isOpenCamera
        ? CrSDK.instance.openVideo(userId)
        : CrSDK.instance.closeVideo(userId);
  }

  // 麦克风开关
  switchMicPhone(bool isOpenMic) {
    isOpenMic
        ? CrSDK.instance.openMic(userId)
        : CrSDK.instance.closeMic(userId);
  }

  // 获取外放状态
  getSpeakerOut() {
    CrSDK.instance.getSpeakerOut().then(
        (bool isSpeakerOut) => setState(() => _isSpeakerOut = isSpeakerOut));
  }

  // 设置外放状态
  void setSpeakerOut(bool isSpeakerOut) {
    setState(() => _isSpeakerOut = isSpeakerOut);
    Utils.debounce("setSpeakerOut", () {
      CrSDK.instance.setSpeakerOut(isSpeakerOut).catchError((value) {
        setState(() => _isSpeakerOut = !isSpeakerOut);
      });
    });
  }

  @override
  audioStatusChanged(CrAudioStatusChanged asc) {
    if (asc.userId == userId) {
      setState(() => _isOpenMic = asc.newStatus == CR_ASTATUS.AOPEN);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("房间号：$confId"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: toHomePage,
          ),
        ),
        body: Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xff1D232F),
            child: Stack(
              children: [
                SizedBox(child: _videoViews),
                Positioned(
                    left: 0,
                    bottom: 0,
                    child: Container(
                      width: ScreenUtil().screenWidth,
                      height: ScreenUtil().setHeight(85),
                      padding: EdgeInsets.symmetric(
                          vertical: ScreenUtil().setHeight(6)),
                      color: Colors.black54,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: ScreenUtil().setWidth(155),
                                  height: ScreenUtil().setHeight(30),
                                  child: ElevatedButton(
                                      child: Text(
                                          "${_isFrontCamera ? '后置' : '前置'}摄像头",
                                          style: TextStyle(
                                              fontSize:
                                                  ScreenUtil().setSp(14))),
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                                // side: BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        5.0))),
                                      ),
                                      onPressed: () {
                                        CR_CAMERA_POSITION cameraPosition =
                                            _isFrontCamera
                                                ? CR_CAMERA_POSITION.BACK
                                                : CR_CAMERA_POSITION.FRONT;
                                        videoViewsKey.currentState
                                            ?.setDefaultVideo(cameraPosition);
                                      }),
                                ),
                                Container(
                                  width: ScreenUtil().setWidth(155),
                                  height: ScreenUtil().setHeight(30),
                                  margin: EdgeInsets.only(
                                      left: ScreenUtil().setHeight(7.5)),
                                  child: ElevatedButton(
                                      child: Text(
                                          "${_isOpenCamera ? '关闭' : '打开'}摄像头"),
                                      style: ButtonStyle(
                                        textStyle: MaterialStateProperty.all(
                                            TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(14))),
                                        shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        5.0))),
                                      ),
                                      onPressed: () {
                                        switchCamera(!_isOpenCamera);
                                      }),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: ScreenUtil().setWidth(155),
                                  height: ScreenUtil().setHeight(30),
                                  child: ElevatedButton(
                                      child: Text(
                                          "${_isOpenMic ? '关闭' : '打开'}麦克风"),
                                      style: ButtonStyle(
                                        textStyle: MaterialStateProperty.all(
                                            TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(14))),
                                        shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        5.0))),
                                      ),
                                      onPressed: () {
                                        switchMicPhone(!_isOpenMic);
                                      }),
                                ),
                                Container(
                                  width: ScreenUtil().setWidth(155),
                                  height: ScreenUtil().setHeight(30),
                                  margin: EdgeInsets.only(
                                      left: ScreenUtil().setHeight(7.5)),
                                  child: ElevatedButton(
                                      child: Text(
                                          "切换为${_isSpeakerOut ? '听筒' : '扬声器'}"),
                                      style: ButtonStyle(
                                        textStyle: MaterialStateProperty.all(
                                            TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(14))),
                                        shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        5.0))),
                                      ),
                                      onPressed: () {
                                        setSpeakerOut(!_isSpeakerOut);
                                      }),
                                )
                              ],
                            ),
                          ]),
                    ))
              ],
            )));
  }
}
