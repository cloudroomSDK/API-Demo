import 'package:cloudroomvideosdk/cloudroomvideosdk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'application/application.dart';

import 'component/video_views.dart';
import 'application/common_func.dart';

GlobalKey<VideoViewsState> videoViewsKey = GlobalKey();

class RemoteRecord extends StatefulWidget {
  const RemoteRecord({Key? key}) : super(key: key);
  @override
  _RemoteRecordState createState() => _RemoteRecordState();
}

class _RemoteRecordState extends State<RemoteRecord>
    with CrSDKNotifier, CommonFunc {
  String userId = GlobalConfig.instance.userID;
  int? confId = GlobalConfig.instance.confID;
  String nickName = GlobalConfig.instance.nickName;
  VideoViews? _videoViews;

  bool _isRecorded = false;

  // 混图器Id
  final int mixerId = 1;

  Color get _buttonColor {
    int color = _isRecorded ? 0xffFF6969 : 0xff3981FC;
    return Color(color);
  }

  @override
  void initState() {
    addCrNotifierListener([
      NOTIFIER_EVENT.lineOff,
      NOTIFIER_EVENT.meetingDropped,
    ]);
    initPage(confId);
    super.initState();
  }

  @override
  void dispose() {
    disposeCrNotifierListener();
    // 停止录制
    if (_isRecorded) {
      CrSDK.instance.stopSvrMixer();
    }
    CrSDK.instance.exitMeeting();
    CrSDK.instance.logout();
    super.dispose();
  }

  @override
  enterMeetingSuccess() {
    // updateVideosCallback 更新混图器
    setState(() {
      _videoViews = VideoViews(
          key: videoViewsKey, updateVideosCallback: updateSvrMixerContent);
    });
    CrSDK.instance.openVideo(userId);
    CrSDK.instance.openMic(userId);
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

  // 文件名
  String getFilename() {
    final DateTime dateTime = DateTime.now();
    final String dir = dateTime.toString().substring(0, 10);
    final String hms =
        dateTime.toString().substring(11, 19).replaceAll(RegExp(r"[\:]"), "-");
    final String _platform = defaultTargetPlatform == TargetPlatform.iOS
        ? "IOS"
        : defaultTargetPlatform == TargetPlatform.android
            ? "Android"
            : "";
    final String filename =
        "/$dir/${dir}_${hms}_Flutter_${_platform}_$confId.mp4";
    return filename;
  }

  // 混图器内容
  List<CrMutiMixerContents> getMutiMixerContent() {
    final ViewInfo? _myViewInfo = videoViewsKey.currentState?.myViewInfo;
    const int recordWidth = 360;
    const int recordHeight = 640;
    final List<CrMutiMixerContent> mmc = [
      CrMutiMixerContent(
          width: recordWidth,
          height: recordHeight,
          left: 0,
          top: 0,
          type: CR_MIXER_VCONTENT_TYPE.MIXVTP_VIDEO,
          keepAspectRatio: CR_KEEP_ASPECT_RATIO.KEEP,
          mutiMixerContentParams: CrMutiMixerContentParams(
              camid:
                  "${_myViewInfo?.usrVideoId?.userId}.${_myViewInfo?.usrVideoId?.videoID}")),
      CrMutiMixerContent(
          left: 0,
          top: 0,
          width: 175,
          height: 32,
          type: CR_MIXER_VCONTENT_TYPE.MIXVTP_TIMESTAMP,
          keepAspectRatio: CR_KEEP_ASPECT_RATIO.KEEP), // 混时间戳
    ];
    // viewsInfo, videoPosition 由 VideoViews 组件提供
    final List<ViewInfo> viewsInfos =
        videoViewsKey.currentState?.viewsinfo ?? [];
    final List<VideoPosition> videoPosition =
        videoViewsKey.currentState?.videoPosition ?? [];

    for (int index = 0; index < viewsInfos.length; index++) {
      ViewInfo vi = viewsInfos[index];
      VideoPosition vp = videoPosition[index];
      int top = (vp.ptop * recordHeight).toInt();
      int left = (vp.pleft * recordWidth).toInt();
      int width = (vp.pwidth * recordWidth).toInt();
      int height = (vp.pheight * recordHeight).toInt();

      mmc.add(CrMutiMixerContent(
          top: top,
          left: left,
          height: height,
          width: width,
          type: CR_MIXER_VCONTENT_TYPE.MIXVTP_VIDEO,
          keepAspectRatio: CR_KEEP_ASPECT_RATIO.KEEP,
          mutiMixerContentParams: CrMutiMixerContentParams(
              camid: "${vi.usrVideoId?.userId}.${vi.usrVideoId?.videoID}")));
    }
    List<CrMutiMixerContents> mutiMixerContents = [
      CrMutiMixerContents(id: mixerId, content: mmc)
    ];
    return mutiMixerContents;
  }

  updateSvrMixerContent() {
    if (_isRecorded) {
      // 获取混图器内容
      List<CrMutiMixerContents> mutiMixerContents = getMutiMixerContent();
      CrSDK.instance.updateSvrMixerContent(mutiMixerContents);
    }
  }

  switchRecord() async {
    if (_isRecorded) {
      // 停止录制
      await CrSDK.instance.stopSvrMixer();
    } else {
      // 开始录制
      final String filename = getFilename();
      // 混图器配置
      List<CrMutiMixerCfg> mutiMixerCfgs = [
        CrMutiMixerCfg(
            id: mixerId,
            streamTypes: CR_STREAM_TYPES.AUDIOANDVIDEO,
            mixerCfg: CrMixerCfg(
                width: 360, height: 640, frameRate: 15, bitRate: 2000000)),
      ];

      // 获取混图器内容
      List<CrMutiMixerContents> mutiMixerContents = getMutiMixerContent();

      // 混图器输出录像配置
      List<CrMutiMixerOutputCfg> mutiMixerOutputCfgs = [
        CrMutiMixerOutputCfg(
            type: CR_MIXER_OUTPUT_TYPE.MIXOT_FILE, filename: filename)
      ];
      // 混图器输出录像
      List<CrMutiMixerOutput> mutiMixerOutput = [
        CrMutiMixerOutput(id: mixerId, mutiMixerOutputCfgs: mutiMixerOutputCfgs)
      ];
      await CrSDK.instance
          .startSvrMixer(mutiMixerCfgs, mutiMixerContents, mutiMixerOutput);
    }
    setState(() {
      _isRecorded = !_isRecorded;
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
          height: double.infinity,
          color: const Color(0xff1D232F),
          child: Stack(
            children: [
              SizedBox(child: _videoViews),
              Positioned(
                left: 0,
                bottom: 0,
                width: ScreenUtil().screenWidth,
                height: ScreenUtil().setHeight(80),
                child: Container(
                    width: ScreenUtil().screenWidth,
                    color: Colors.black87,
                    child: Center(
                      child: SizedBox(
                        // width: ScreenUtil().setWidth(85),
                        height: ScreenUtil().setHeight(30),
                        child: ElevatedButton(
                            child: Text("${_isRecorded ? '结束' : '开始'}录制",
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(14))),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(_buttonColor),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(5.0))),
                            ),
                            onPressed: () {
                              switchRecord();
                            }),
                      ),
                    )),
              )
            ],
          ),
        ));
  }
}
