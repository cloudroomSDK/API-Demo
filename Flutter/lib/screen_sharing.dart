import 'dart:async';

import 'package:cloudroomvideosdk/cloudroomvideosdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'application/application.dart';

import 'application/common_func.dart';

class ScreenSharing extends StatefulWidget {
  const ScreenSharing({Key? key}) : super(key: key);

  @override
  _ScreenSharingWidgetState createState() => _ScreenSharingWidgetState();
}

class _ScreenSharingWidgetState extends State<ScreenSharing>
    with CrSDKNotifier, CommonFunc {
  String userId = GlobalConfig.instance.userID;
  int? confId = GlobalConfig.instance.confID;
  String nickName = GlobalConfig.instance.nickName;
  bool _isOpenMic = false; // 是否开启麦克风
  bool _isScreenShareStarted = false;
  bool _isViewScreenShare = false; // 是否观看共享
  int? _screenViewID;
  Widget? _screenViewWidget;

  Color get _buttonColor {
    int color = _isScreenShareStarted ? 0xffFF6969 : 0xff3981FC;
    return Color(color);
  }

  @override
  void initState() {
    addCrNotifierListener([
      NOTIFIER_EVENT.lineOff,
      NOTIFIER_EVENT.meetingDropped,
      NOTIFIER_EVENT.notifyScreenShareStarted,
      NOTIFIER_EVENT.notifyScreenShareStopped,
      NOTIFIER_EVENT.notifyScreenMarkStarted,
      NOTIFIER_EVENT.notifyScreenMarkStopped,
      NOTIFIER_EVENT.audioStatusChanged,
    ]);
    initPage(confId);
    super.initState();
  }

  @override
  void dispose() {
    disposeCrNotifierListener();
    destroyScreenShareView();
    CrSDK.instance.exitMeeting();
    CrSDK.instance.logout();
    super.dispose();
  }

  @override
  enterMeetingSuccess() {
    createScreenShareView();
    setScreenShareCfg();
    getIsScreenShareStarted();
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

  @override
  audioStatusChanged(CrAudioStatusChanged asc) {
    if (asc.userId == userId) {
      setState(() => _isOpenMic = asc.newStatus == CR_ASTATUS.AOPEN);
    }
  }

  // 麦克风开关
  switchMicPhone(bool isOpenMic) {
    if (isOpenMic) {
      CrSDK.instance.openMic(userId);
      CrSDK.instance.setSpeakerOut(true);
    } else {
      CrSDK.instance.closeMic(userId);
    }
  }

  // 通知开启屏幕共享
  @override
  void notifyScreenShareStarted() {
    setState(() {
      _isScreenShareStarted = true;
      _isViewScreenShare = true;
    });
  }

  // 通知停止屏幕共享
  @override
  void notifyScreenShareStopped() {
    setState(() {
      _isScreenShareStarted = false;
      _isViewScreenShare = false;
    });
  }

  // 通知开启屏幕共享标注
  @override
  void notifyScreenMarkStarted() {}

  // 通知停止屏幕共享标注
  @override
  void notifyScreenMarkStopped() {}

  getIsScreenShareStarted() {
    return CrSDK.instance
        .isScreenShareStarted()
        .then((bool isScreenShareStarted) {
      setState(() {
        _isScreenShareStarted = isScreenShareStarted;
        _isViewScreenShare = isScreenShareStarted;
      });
    });
  }

  createScreenShareView() {
    _screenViewWidget = CrSDK.instance.createScreenShareView((int viewID) {
      _screenViewID = viewID;
    });
  }

  Future<void> destroyScreenShareView() {
    return CrSDK.instance.destroyScreenShareView(_screenViewID!);
  }

  setScreenShareCfg() {
    CrSDK.instance.getScreenShareCfg().then((CrScreenShareCfg cfg) {
      cfg.maxBps = 2000000;
      cfg.maxFps = 12;
      CrSDK.instance.setScreenShareCfg(cfg);
    });
  }

  // 开关屏幕共享
  Future switchScreenShare(bool isScreenShareStarted) {
    setState(() {
      _isScreenShareStarted = isScreenShareStarted;
    });
    return isScreenShareStarted
        ? CrSDK.instance.startScreenShare().then((int sdkErr) {
            if (sdkErr != 0) {
              setState(() => _isScreenShareStarted = !isScreenShareStarted);
            }
          })
        : CrSDK.instance.stopScreenShare().then((int sdkErr) {
            if (sdkErr != 0) {
              setState(() => _isScreenShareStarted = !isScreenShareStarted);
            }
          });
  }

  Widget getWaitStartSharedWidget() {
    return Positioned(
        child: Padding(
      padding: EdgeInsets.only(
          top: ScreenUtil().setHeight(38),
          left: ScreenUtil().setWidth(35),
          right: ScreenUtil().setWidth(35)),
      child: Column(
        children: [
          Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 10),
              child: Text("房间号：$confId",
                  style: const TextStyle(color: Colors.white, fontSize: 14))),
          Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 10),
              child: Text("用户名：$nickName",
                  style: const TextStyle(color: Colors.white, fontSize: 14))),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 10),
            child: const Text("请在其他设备上使用观众身份进入相同的房间观看",
                style: TextStyle(color: Colors.white, fontSize: 14)),
          ),
          Container(
            padding: const EdgeInsets.only(top: 53),
            child: Center(
                child: Text("${_isScreenShareStarted ? "您正在" : ""}共享屏幕",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtil().setSp(18)))),
          ),
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setHeight(36)),
            width: ScreenUtil().setWidth(186),
            height: ScreenUtil().setHeight(65),
            child: ElevatedButton(
                child: Text("${_isScreenShareStarted ? '停止' : '开始'}屏幕共享"),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(_buttonColor),
                  textStyle: MaterialStateProperty.all(
                      TextStyle(fontSize: ScreenUtil().setSp(16))),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0))),
                ),
                onPressed: () {
                  switchScreenShare(!_isScreenShareStarted);
                }),
          ),
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setHeight(230)),
            width: ScreenUtil().setWidth(125),
            height: ScreenUtil().setHeight(30),
            child: ElevatedButton(
                child: Text("${_isOpenMic ? '关闭' : '打开'}麦克风"),
                style: ButtonStyle(
                  textStyle: MaterialStateProperty.all(
                      TextStyle(fontSize: ScreenUtil().setSp(14))),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0))),
                ),
                onPressed: () {
                  switchMicPhone(!_isOpenMic);
                }),
          )
        ],
      ),
    ));
  }

  Widget getViewSharedWidget() {
    return Positioned(
        left: ScreenUtil().setWidth(137.5),
        bottom: ScreenUtil().setHeight(15),
        child: SizedBox(
          width: ScreenUtil().setWidth(100),
          height: ScreenUtil().setHeight(30),
          child: ElevatedButton(
              child: const Text("退出"),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(const Color(0xffF44E4E)),
                textStyle: MaterialStateProperty.all(
                    TextStyle(fontSize: ScreenUtil().setSp(14))),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0))),
              ),
              onPressed: toHomePage),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("屏幕共享"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: toHomePage,
        ),
      ),
      body: Container(
        color: Colors.black,
        child: Stack(children: [
          Center(
            child: Container(
              color: Colors.blue,
              child: _screenViewWidget,
            ),
          ),
          _isViewScreenShare
              ? getViewSharedWidget()
              : getWaitStartSharedWidget()
        ]),
      ),
    );
  }
}
