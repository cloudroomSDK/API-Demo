import 'package:cloudroomvideosdk/cloudroomvideosdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'application/application.dart';

import 'component/video_views.dart';
import 'application/common_func.dart';

GlobalKey<VideoViewsState> videoViewsKey = GlobalKey();

class LocalRecord extends StatefulWidget {
  const LocalRecord({Key? key}) : super(key: key);
  @override
  _LocalRecordState createState() => _LocalRecordState();
}

class _LocalRecordState extends State<LocalRecord>
    with CrSDKNotifier, CommonFunc {
  String userId = GlobalConfig.instance.userID;
  int? confId = GlobalConfig.instance.confID;
  String nickName = GlobalConfig.instance.nickName;
  late TextEditingController _recordNameController;
  VideoViews? _videoViews;

  // 混图器Id
  final String mixerId = "1";
  bool _isRecorded = false;
  final CrMixerCfg cfg = CrMixerCfg(
      width: 360,
      height: 640,
      frameRate: 15,
      bitRate: 500000,
      defaultQP: 26,
      gop: 15); // 混图器配置

  @override
  void initState() {
    addCrNotifierListener([
      NOTIFIER_EVENT.lineOff,
      NOTIFIER_EVENT.meetingDropped,
      NOTIFIER_EVENT.locMixerOutputInfo,
    ]);
    _recordNameController = TextEditingController();
    initPage(confId);
    super.initState();
  }

  @override
  void dispose() {
    disposeCrNotifierListener();
    _recordNameController.dispose();
    if (_isRecorded) {
      CrSDK.instance.destroyLocMixer(mixerId);
    }
    CrSDK.instance.exitMeeting();
    CrSDK.instance.logout();
    super.dispose();
  }

  @override
  enterMeetingSuccess() {
    setState(() {
      _videoViews = VideoViews(
          key: videoViewsKey, updateVideosCallback: updateLocMixerContent);
    });
    CrSDK.instance.openVideo(userId);
    CrSDK.instance.openMic(userId);
    setFileName();
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
  locMixerOutputInfo(CrMixerOutputInfo mixerOutputInfo) {
    if (mixerOutputInfo.state == CR_MIXER_OUTPUT_STATE.OUTPUT_ERR) {
      CrErrorDef err = CrErrorDef(mixerOutputInfo.errCode);
      EasyLoading.showToast(err.message);
      setState(() {
        _isRecorded = false;
      });
    }
  }

  setFileName() {
    final DateTime dateTime = DateTime.now();
    final String dir = dateTime.toString().substring(0, 10);
    final String hms =
        dateTime.toString().substring(11, 19).replaceAll(RegExp(r"[\:]"), "-");
    // final String filename = dateTime
    //     .toString()
    //     .replaceAll(RegExp(r"[\:|\s|\-]"), "")
    //     .substring(0, 14);
    final String filename = "${dir}_${hms}_$confId";
    _recordNameController.text = filename;
  }

  // 混图器内容
  List<CrMixerCotentRect> getMixerCotentRect() {
    int mcrWidth = cfg.width;
    int mcrHeight = cfg.height;
    final List<CrMixerCotentRect> mcr = [
      CrMixerCotentRect(
          userId: userId,
          camId: -1,
          type: CR_MIXER_VCONTENT_TYPE.MIXVTP_VIDEO,
          top: 0,
          left: 0,
          width: mcrWidth,
          height: mcrHeight),
      CrMixerCotentRect(
          left: 0,
          top: 0,
          width: 175,
          height: 32,
          type: CR_MIXER_VCONTENT_TYPE.MIXVTP_TIMESTAMP), // 混时间戳
    ];

    final List<ViewInfo> viewsInfos =
        videoViewsKey.currentState?.viewsinfo ?? [];
    final List<VideoPosition> videoPosition =
        videoViewsKey.currentState?.videoPosition ?? [];

    for (int index = 0; index < viewsInfos.length; index++) {
      ViewInfo vi = viewsInfos[index];
      VideoPosition vp = videoPosition[index];
      int top = (vp.ptop * mcrHeight).toInt();
      int left = (vp.pleft * mcrWidth).toInt();
      int width = (vp.pwidth * mcrWidth).toInt();
      int height = (vp.pheight * mcrHeight).toInt();
      CrMixerCotentRect mixercr = CrMixerCotentRect(
          userId: vi.usrVideoId?.userId,
          camId: vi.usrVideoId?.videoID,
          type: CR_MIXER_VCONTENT_TYPE.MIXVTP_VIDEO,
          top: top,
          left: left,
          height: height,
          width: width);
      mcr.add(mixercr);
    }
    return mcr;
  }

  updateLocMixerContent() {
    // 是否在录制，是的话要更新混图器
    if (_isRecorded) {
      List<CrMixerCotentRect> mcr = getMixerCotentRect();
      CrSDK.instance.updateLocMixerContent(mixerId, mcr);
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
              _isRecorded
                  ? Positioned(
                      right: ScreenUtil().setWidth(13),
                      bottom: ScreenUtil().setHeight(11),
                      child: SizedBox(
                        // width: ScreenUtil().setWidth(85),
                        height: ScreenUtil().setHeight(30),
                        child: ElevatedButton(
                            child: Text("结束录制",
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(14))),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  const Color(0xffFF6969)),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(5.0))),
                            ),
                            onPressed: () async {
                              await CrSDK.instance.destroyLocMixer(mixerId);
                              setFileName();
                              setState(() {
                                _isRecorded = false;
                              });
                            }),
                      ),
                    )
                  : Positioned(
                      left: 0,
                      bottom: 0,
                      child: Container(
                        width: ScreenUtil().screenWidth,
                        height: ScreenUtil().setHeight(80),
                        color: Colors.black,
                        padding: EdgeInsets.only(
                            top: ScreenUtil().setHeight(14),
                            bottom: ScreenUtil().setHeight(11),
                            left: ScreenUtil().setWidth(18),
                            right: ScreenUtil().setWidth(13)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("请输入文件名",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil().setSp(14))),
                            Row(
                              children: [
                                Expanded(
                                    child: SizedBox(
                                        height: ScreenUtil().setHeight(30),
                                        child: TextFormField(
                                            controller: _recordNameController,
                                            style: const TextStyle(
                                                color: CrColors.textPrimary),
                                            cursorColor: CrColors.textPrimary,
                                            decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        ScreenUtil()
                                                            .setWidth(15),
                                                        ScreenUtil()
                                                            .setHeight(8),
                                                        ScreenUtil()
                                                            .setWidth(15),
                                                        ScreenUtil()
                                                            .setHeight(8)),
                                                floatingLabelBehavior:
                                                    FloatingLabelBehavior
                                                        .always, // labelText的浮动状态
                                                enabledBorder:
                                                    const OutlineInputBorder(
                                                  //未选中时候的颜色
                                                  borderSide: BorderSide(
                                                    color: CrColors.borderColor,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    const OutlineInputBorder(
                                                  //选中时外边框颜色
                                                  borderSide: BorderSide(
                                                    color: CrColors.borderColor,
                                                  ),
                                                ))))),
                                Container(
                                  height: ScreenUtil().setHeight(30),
                                  margin: const EdgeInsets.only(left: 10),
                                  child: ElevatedButton(
                                      child: const Text("开始录制"),
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
                                      onPressed: () async {
                                        final String filename =
                                            _recordNameController.text.trim();
                                        if (filename != "") {
                                          // 获取混图器内容
                                          final List<CrMixerCotentRect> mcr =
                                              getMixerCotentRect();
                                          // 创建混图器
                                          await CrSDK.instance.createLocMixer(
                                              mixerId, cfg, mcr);
                                          // 添加输出到录像文件
                                          final String fileName =
                                              "${GlobalConfig.instance.sdkDatSavePath}/$filename.mp4";
                                          CrMixerOutPutCfg mixerOutPutCfg =
                                              CrMixerOutPutCfg(
                                                  type: CR_MIXER_OUTPUT_TYPE
                                                      .MIXOT_FILE,
                                                  fileName: fileName);
                                          List<CrMixerOutPutCfg>
                                              mixerOutPutCfgs = [
                                            mixerOutPutCfg
                                          ];
                                          await CrSDK.instance
                                              .addLocMixerOutput(
                                                  mixerId, mixerOutPutCfgs);
                                          setState(() {
                                            _isRecorded = true;
                                          });
                                        } else {
                                          EasyLoading.showToast("录制名称不能为空");
                                        }
                                      }),
                                )
                              ],
                            )
                          ],
                        ),
                      ))
            ],
          ),
        ));
  }
}
