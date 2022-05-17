import 'package:cloudroomvideosdk_example/application/common_func.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:cloudroomvideosdk/cloudroomvideosdk.dart';
import 'application/application.dart';

class AudioChannel extends StatefulWidget {
  const AudioChannel({Key? key}) : super(key: key);

  @override
  _AudioChannelState createState() => _AudioChannelState();
}

class _AudioChannelState extends State<AudioChannel>
    with CrSDKNotifier, CommonFunc {
  String userId = GlobalConfig.instance.userID;
  int? confId = GlobalConfig.instance.confID;
  String nickName = GlobalConfig.instance.nickName;

  bool _isOpenMic = false; // 是否开启麦克风
  bool _isSpeakerOut = false; // 是否外放（扬声器）
  double _localVolume = 0; // 本地音量
  double _remoteVolume = 0; // 远端音量
  String _remoteNickName = "远端用户";

  @override
  void initState() {
    addCrNotifierListener([
      NOTIFIER_EVENT.lineOff,
      NOTIFIER_EVENT.meetingDropped,
      NOTIFIER_EVENT.micEnergyUpdate,
      NOTIFIER_EVENT.userLeftMeeting,
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

  // 用户离开
  @override
  userLeftMeeting(String uid) {
    if (uid == _remoteNickName) {
      _remoteVolume = 0;
      _remoteNickName = "远端用户";
    }
  }

  // 通知用户的说话声音强度更新
  @override
  micEnergyUpdate(CrMicEnergy energy) {
    bool isMySelf = energy.userId == userId;
    int newLevel = energy.newLevel;
    double volume = (newLevel / 10).toDouble(); // 范围 0 ~ 10，组件接收 0 ~ 1
    setState(() {
      if (isMySelf) {
        _localVolume = volume;
      } else {
        _remoteVolume = volume;
        _remoteNickName = energy.userId;
      }
    });
  }

  @override
  audioStatusChanged(CrAudioStatusChanged asc) {
    if (asc.userId == userId) {
      setState(() => _isOpenMic = asc.newStatus == CR_ASTATUS.AOPEN);
    }
  }

  // 麦克风开关
  void switchMicPhone(bool isOpenMic) {
    isOpenMic
        ? CrSDK.instance.openMic(userId)
        : CrSDK.instance.closeMic(userId);
  }

  // 获取外放状态
  void getSpeakerOut() {
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
            color: const Color(0xff1D232F),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: double.infinity,
                    height: ScreenUtil().setHeight(76.5),
                    margin: EdgeInsets.only(top: ScreenUtil().setHeight(192)),
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage("assets/images/voiceprint.png"),
                      fit: BoxFit.cover,
                    )),
                  ),
                  Container(
                    width: ScreenUtil().setWidth(205),
                    // height: ScreenUtil().setHeight(100),
                    margin: EdgeInsets.only(
                        top: ScreenUtil().setHeight(54),
                        bottom: ScreenUtil().setHeight(95)),
                    padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                    color: Colors.black,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              bottom: ScreenUtil().setHeight(4)),
                          child: Text(nickName,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenUtil().setSp(12))),
                        ),
                        LinearProgressIndicator(
                          minHeight: 5,
                          value: _localVolume,
                          backgroundColor: const Color(0xff373F50),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xff09DB00)),
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                                top: ScreenUtil().setHeight(15),
                                bottom: ScreenUtil().setHeight(4)),
                            child: Text(_remoteNickName,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil().setSp(12)))),
                        LinearProgressIndicator(
                          minHeight: 5,
                          value: _remoteVolume,
                          backgroundColor: const Color(0xff373F50),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xff09DB00)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: ScreenUtil().setHeight(85),
                    color: Colors.black,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: ScreenUtil().setWidth(155),
                                height: ScreenUtil().setHeight(30),
                                child: ElevatedButton(
                                    child:
                                        Text("${_isOpenMic ? '关闭' : '打开'}麦克风"),
                                    style: ButtonStyle(
                                      textStyle: MaterialStateProperty.all(
                                          TextStyle(
                                              fontSize:
                                                  ScreenUtil().setSp(14))),
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0))),
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
                                        "切换为${_isSpeakerOut ? '听筒' : '扬声器'}",
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setSp(14))),
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0))),
                                    ),
                                    onPressed: () {
                                      setSpeakerOut(!_isSpeakerOut);
                                    }),
                              )
                            ],
                          ),
                          Container(
                            width: ScreenUtil().setWidth(100),
                            height: ScreenUtil().setHeight(30),
                            margin:
                                EdgeInsets.only(top: ScreenUtil().setHeight(7)),
                            child: ElevatedButton(
                                child: Text("挂断",
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(14))),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      const Color(0xfff44e4e)),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0))),
                                ),
                                onPressed: toHomePage),
                          )
                        ]),
                  )
                ],
              ),
            )));
  }
}
