import 'package:cloudroomvideosdk/cloudroomvideosdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'application/application.dart';

import 'component/video_views.dart';
import 'application/common_func.dart';

class VideoRatio {
  int width;
  int height;
  late String text;
  double maxkbps;
  late double minkbps;

  VideoRatio(this.height, this.width, this.maxkbps) {
    text = "${height}P";
    minkbps = maxkbps / 4;
  }
}

class VideoConfig extends StatefulWidget {
  const VideoConfig({Key? key}) : super(key: key);

  @override
  _VideoConfigState createState() => _VideoConfigState();
}

class _VideoConfigState extends State<VideoConfig>
    with CrSDKNotifier, CommonFunc {
  String userId = GlobalConfig.instance.userID;
  int? confId = GlobalConfig.instance.confID;
  String nickName = GlobalConfig.instance.nickName;
  VideoRatio? _ratio;
  double _minkbps = 0;
  double _maxkbps = 0;
  double _kbps = 0;
  double _fps = 15;
  late CrVideoCfg _cfg;
  VideoViews? _videoViews;

  List<VideoRatio> vratio = [
    VideoRatio(360, 640, 700), // 0.7M，取1024 * 0.7的话会有小数点
    VideoRatio(480, 848, 1024),
    VideoRatio(720, 1280, 2048),
    VideoRatio(1080, 1920, 4096),
  ];

  @override
  void initState() {
    addCrNotifierListener([
      NOTIFIER_EVENT.lineOff,
      NOTIFIER_EVENT.meetingDropped,
      NOTIFIER_EVENT.videoStatusChanged,
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
  enterMeetingSuccess() async {
    _cfg = await CrSDK.instance.getVideoCfg();
    switchRatio(vratio.first, isInit: true);
    CrSDK.instance.openVideo(userId);
    setState(() {
      _videoViews = VideoViews();
    });
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
      print(vsc.newStatus);
    }
  }

  Future<void> setVideoCfg() {
    _cfg.size = CrSize(width: _ratio!.width, height: _ratio!.height);
    _cfg.fps = _fps.toInt();
    _cfg.maxbps = _kbps.toInt() * 1000;
    return CrSDK.instance.setVideoCfg(_cfg);
  }

  List<Widget> generatorRatio() {
    return vratio.map((ratio) {
      Color color = _ratio == ratio ? CrColors.primary : Colors.white;
      return SizedBox(
          width: ScreenUtil().setWidth(72),
          child: OutlinedButton(
            child: Text(ratio.text, style: TextStyle(color: color)),
            style: ButtonStyle(
              side: MaterialStateProperty.all(BorderSide(color: color)),
            ),
            onPressed: () {
              switchRatio(ratio);
            },
          ));
    }).toList();
  }

  // 切换分辨率
  void switchRatio(VideoRatio ratio, {bool isInit = false}) {
    if (_ratio != ratio) {
      void setRatio() {
        _ratio = ratio;
        _minkbps = ratio.minkbps;
        _maxkbps = ratio.maxkbps;
        _kbps = ratio.minkbps + ((ratio.maxkbps - ratio.minkbps) / 2);
      }

      isInit ? setRatio() : setState(setRatio);
      setVideoCfg();
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
                    color: Colors.black45,
                    padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(26),
                        right: ScreenUtil().setWidth(26),
                        top: ScreenUtil().setHeight(15),
                        bottom: ScreenUtil().setHeight(15)),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("分辨率",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenUtil().setSp(14))),
                          Padding(
                              padding: EdgeInsets.only(
                                  top: ScreenUtil().setWidth(18)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: generatorRatio(),
                              )),
                          Padding(
                            padding: EdgeInsets.only(
                                top: ScreenUtil().setHeight(10)),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: ScreenUtil().setWidth(28),
                                  child: Text(
                                    "码率",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: ScreenUtil().setSp(14)),
                                  ),
                                ),
                                Expanded(
                                    child: SliderTheme(
                                        data: const SliderThemeData(
                                          trackHeight: 2.0,
                                        ),
                                        child: Slider(
                                            value: _kbps,
                                            min: _minkbps,
                                            max: _maxkbps,
                                            divisions: 100,
                                            label: _kbps.round().toString(),
                                            inactiveColor:
                                                const Color(0xffB1B1B1),
                                            onChanged: (double value) {
                                              setState(() {
                                                _kbps = value;
                                              });
                                            },
                                            onChangeEnd: (double value) {
                                              setVideoCfg();
                                            }))),
                                SizedBox(
                                  width: ScreenUtil().setWidth(60),
                                  child: Text(
                                    "${_kbps.round().toString()}kbps",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: ScreenUtil().setSp(14)),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                bottom: ScreenUtil().setHeight(10)),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: ScreenUtil().setWidth(28),
                                  child: Text(
                                    "帧率",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: ScreenUtil().setSp(14)),
                                  ),
                                ),
                                Expanded(
                                    child: SliderTheme(
                                        data: const SliderThemeData(
                                          trackHeight: 2.0,
                                        ),
                                        child: Slider(
                                            value: _fps,
                                            min: 5,
                                            max: 30,
                                            divisions: 25,
                                            label: _fps.round().toString(),
                                            inactiveColor:
                                                const Color(0xffB1B1B1),
                                            onChanged: (double value) {
                                              setState(() {
                                                _fps = value;
                                              });
                                            },
                                            onChangeEnd: (double value) {
                                              setVideoCfg();
                                            }))),
                                SizedBox(
                                  width: ScreenUtil().setWidth(60),
                                  child: Text(
                                    "${_fps.round().toString()}fps",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: ScreenUtil().setSp(14)),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin:
                                EdgeInsets.only(top: ScreenUtil().setHeight(7)),
                            child: Center(
                              child: SizedBox(
                                width: ScreenUtil().setWidth(100),
                                height: ScreenUtil().setHeight(30),
                                child: ElevatedButton(
                                    child: Text("退出",
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setSp(14))),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              const Color(0xfff44e4e)),
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0))),
                                    ),
                                    onPressed: toHomePage),
                              ),
                            ),
                          )
                        ]),
                  ))
            ],
          ),
        ));
  }
}
