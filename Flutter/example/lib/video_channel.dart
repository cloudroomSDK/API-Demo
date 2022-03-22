import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'application/application.dart';
import 'package:cloudroomvideosdk/cloudroomvideosdk.dart';
import 'component/video_views.dart';
import 'component/common_func.dart';
import 'component/common_audio.dart';
import 'component/common_video.dart';

class VideoChannel extends StatefulWidget {
  const VideoChannel({Key? key}) : super(key: key);

  @override
  _VideoChannelState createState() => _VideoChannelState();
}

class _VideoChannelState extends State<VideoChannel>
    with CommonFunc, CommonVideo, CommonAudio {
  String userId = GlobalConfig.instance.userID;
  int? confId = GlobalConfig.instance.confID;
  String nickName = GlobalConfig.instance.nickName;
  VideoViews? _videoViews;

  @override
  void initState() {
    addSDKAuthObserver(this);
    addSDKVideoObserver(this);
    addSDKAudioObserver(this);
    init();
    super.initState();
  }

  @override
  void dispose() {
    removeSDKAuthObserver();
    removeSDKVideoObserver();
    removeSDKAudioObserver();
    super.dispose();
  }

  init() async {
    await enterMeeting();
    getSpeakerOut();
    switchCamera(userId, true);
    await getDefaultVideo(userId);
    // 获取的摄像头不是前置摄像头就改成前置摄像头
    if (defaultCameraInfo?.cameraPosition != CR_CAMERA_POSITION.FRONT) {
      setDefaultVideo(userId, CR_CAMERA_POSITION.FRONT);
    }
    _videoViews = const VideoViews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("房间号：$confId"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              exitMeeting();
            },
          ),
        ),
        body: WillPopScope(
            onWillPop: () async {
              return await exitMeeting();
            },
            child: Container(
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
                                              "${isFrontCamera ? '后置' : '前置'}摄像头",
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
                                                isFrontCamera
                                                    ? CR_CAMERA_POSITION.BACK
                                                    : CR_CAMERA_POSITION.FRONT;
                                            setDefaultVideo(
                                                userId, cameraPosition);
                                          }),
                                    ),
                                    Container(
                                      width: ScreenUtil().setWidth(155),
                                      height: ScreenUtil().setHeight(30),
                                      margin: EdgeInsets.only(
                                          left: ScreenUtil().setHeight(7.5)),
                                      child: ElevatedButton(
                                          child: Text(
                                              "${isOpenCamera ? '关闭' : '打开'}摄像头"),
                                          style: ButtonStyle(
                                            textStyle:
                                                MaterialStateProperty.all(
                                                    TextStyle(
                                                        fontSize: ScreenUtil()
                                                            .setSp(14))),
                                            shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0))),
                                          ),
                                          onPressed: () {
                                            switchCamera(userId, !isOpenCamera);
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
                                              "${isOpenMic ? '关闭' : '打开'}麦克风"),
                                          style: ButtonStyle(
                                            textStyle:
                                                MaterialStateProperty.all(
                                                    TextStyle(
                                                        fontSize: ScreenUtil()
                                                            .setSp(14))),
                                            shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0))),
                                          ),
                                          onPressed: () {
                                            switchMicPhone(userId, !isOpenMic);
                                          }),
                                    ),
                                    Container(
                                      width: ScreenUtil().setWidth(155),
                                      height: ScreenUtil().setHeight(30),
                                      margin: EdgeInsets.only(
                                          left: ScreenUtil().setHeight(7.5)),
                                      child: ElevatedButton(
                                          child: Text(
                                              "切换为${isSpeakerOut ? '听筒' : '扬声器'}"),
                                          style: ButtonStyle(
                                            textStyle:
                                                MaterialStateProperty.all(
                                                    TextStyle(
                                                        fontSize: ScreenUtil()
                                                            .setSp(14))),
                                            shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0))),
                                          ),
                                          onPressed: () {
                                            setSpeakerOut(!isSpeakerOut);
                                          }),
                                    )
                                  ],
                                ),
                              ]),
                        ))
                  ],
                ))));
  }
}
