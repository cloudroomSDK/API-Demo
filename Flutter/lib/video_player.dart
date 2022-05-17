import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:cloudroomvideosdk/cloudroomvideosdk.dart';
import 'package:file_picker/file_picker.dart';
import 'application/application.dart';
import 'application/common_func.dart';

class VideoPlayer extends StatefulWidget {
  const VideoPlayer({Key? key}) : super(key: key);
  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer>
    with CrSDKNotifier, CommonFunc {
  String userId = GlobalConfig.instance.userID;
  int? confId = GlobalConfig.instance.confID;
  String nickName = GlobalConfig.instance.nickName;
  late TextEditingController _fileNameController;
  int? _mediaViewID;
  Widget? _mediaViewWidget;
  bool _isStartPlay = false;
  bool _isMyStartPlay = false;
  bool _pause = true; // 是否暂停
  bool _isShowPauseBtn = false;
  Timer? _pauseBtnTimer;

  set isStartPlay(bool isstartplay) {
    _isStartPlay = isstartplay;
    _pause = !isstartplay;
  }

  @override
  void initState() {
    _fileNameController = TextEditingController();
    addCrNotifierListener([
      NOTIFIER_EVENT.lineOff,
      NOTIFIER_EVENT.meetingDropped,
      NOTIFIER_EVENT.notifyMediaStart,
      NOTIFIER_EVENT.notifyMediaPause,
      NOTIFIER_EVENT.notifyMediaStop,
    ]);
    initPage(confId);
    super.initState();
  }

  @override
  void dispose() {
    disposeCrNotifierListener();
    _fileNameController.dispose();
    destroyMediaView();
    CrSDK.instance.exitMeeting();
    CrSDK.instance.logout();
    super.dispose();
  }

  @override
  enterMeetingSuccess() {
    getMediaInfo();
    CrVideoCfg cfg = CrVideoCfg(
      size: CrSize(width: 360, height: 640),
      fps: 20,
    );
    CrSDK.instance.setMediaCfg(cfg);
    createMediaView();
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

  void getMediaInfo() {
    CrSDK.instance.getMediaInfo().then((CrMediaInfo mediaInfo) {
      if (mediaInfo.state == CR_MEDIA_STATE.MEDIA_START ||
          mediaInfo.state == CR_MEDIA_STATE.MEDIA_PAUSE) {
        setState(() {
          isStartPlay = true;
        });
      }
    });
  }

  // 手动开启影音共享
  void startPlayMedia(String path) {
    setState(() {
      isStartPlay = true;
    });
    CrSDK.instance.startPlayMedia(path);
  }

  void pausePlayMedia(bool pause) {
    setState(() => _pause = pause);
    CrSDK.instance.pausePlayMedia(pause);
  }

  // 手动停止影音共享
  void stopPlayMedia() {
    setState(() {
      isStartPlay = false;
    });
    CrSDK.instance.stopPlayMedia();
  }

  // 通知影音开始播放
  @override
  void notifyMediaStart(CrMediaNotify data) {
    setState(() {
      isStartPlay = true;
      _isMyStartPlay = data.userID == userId;
    });
  }

  // 通知影音是否暂停播放
  @override
  void notifyMediaPause(CrMediaNotify data) {
    setState(() {
      _pause = data.pause ?? true;
    });
  }

  // 通知停止影音共享
  @override
  void notifyMediaStop(CrMediaNotify data) {
    setState(() {
      isStartPlay = false;
    });
  }

  void createMediaView() {
    setState(() {
      _mediaViewWidget = CrSDK.instance.createMediaView((viewID) {
        _mediaViewID = viewID;
      });
    });
  }

  void destroyMediaView() {
    CrSDK.instance.destroyMediaView(_mediaViewID!);
  }

  Widget getNotStartPlayWidget() {
    return Stack(
      children: [
        SizedBox(
          child: GestureDetector(
            onPanDown: (DragDownDetails details) {
              if (_isStartPlay) {
                setState(() => _isShowPauseBtn = true);
                _pauseBtnTimer?.cancel();
                _pauseBtnTimer = Timer(const Duration(seconds: 4), () {
                  _pauseBtnTimer = null;
                  setState(() => _isShowPauseBtn = false);
                });
              }
            },
            child: _mediaViewWidget,
          ),
        ),
        Positioned(
            child: SizedBox(
          child: _isShowPauseBtn && _isStartPlay
              ? GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: SizedBox(
                      width: ScreenUtil().setWidth(100),
                      height: ScreenUtil().setWidth(100),
                      child: IconButton(
                          onPressed: () {
                            pausePlayMedia(!_pause);
                          },
                          icon: Icon(
                              _pause
                                  ? Icons.play_circle_outlined
                                  : Icons.pause_circle_outlined,
                              size: 64,
                              color: Colors.white)),
                    ),
                  ),
                )
              : null,
        )),
        Positioned(
          left: 0,
          bottom: 0,
          child: Container(
            width: ScreenUtil().screenWidth,
            height: ScreenUtil().setHeight(80),
            padding:
                EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(15)),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: SizedBox(
                            height: ScreenUtil().setHeight(30),
                            child: TextFormField(
                                controller: _fileNameController,
                                style: const TextStyle(
                                    color: CrColors.textPrimary),
                                cursorColor: CrColors.textPrimary,
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: ScreenUtil().setHeight(8),
                                        horizontal: ScreenUtil().setWidth(15)),
                                    floatingLabelBehavior: FloatingLabelBehavior
                                        .always, // labelText的浮动状态
                                    enabledBorder: const OutlineInputBorder(
                                      //未选中时候的颜色
                                      borderSide: BorderSide(
                                        color: CrColors.borderColor,
                                      ),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      //选中时外边框颜色
                                      borderSide: BorderSide(
                                        color: CrColors.borderColor,
                                      ),
                                    ))))),
                    Container(
                      height: ScreenUtil().setHeight(30),
                      margin: const EdgeInsets.only(left: 10),
                      child: ElevatedButton(
                          child: const Text("选择文件"),
                          style: ButtonStyle(
                            textStyle: MaterialStateProperty.all(
                                TextStyle(fontSize: ScreenUtil().setSp(14))),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0))),
                          ),
                          onPressed: () async {
                            FilePickerResult? filePickerResult =
                                await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: [
                                'mp4',
                                'mov',
                                'rmvb',
                                'rm',
                                'flv',
                                '3gp'
                              ],
                            );
                            if (filePickerResult != null) {
                              String? path = filePickerResult.files.single.path;
                              if (path != null) {
                                stopPlayMedia();
                                setState(() {
                                  _fileNameController.text = path;
                                });
                              }
                            }
                          }),
                    )
                  ],
                ),
                Container(
                  height: ScreenUtil().setHeight(30),
                  margin: const EdgeInsets.only(top: 12),
                  child: ElevatedButton(
                      child: Text("${_isStartPlay ? '停止' : '开始'}播放"),
                      style: ButtonStyle(
                        textStyle: MaterialStateProperty.all(
                            TextStyle(fontSize: ScreenUtil().setSp(14))),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                      ),
                      onPressed: () {
                        String path = _fileNameController.text.trim();
                        if (path != "") {
                          if (!_isStartPlay) {
                            startPlayMedia(path);
                          } else {
                            stopPlayMedia();
                          }
                        } else {
                          EasyLoading.showToast("请选择播放文件");
                        }
                      }),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget getViewPlayWidget() {
    return Stack(children: [
      Container(color: Colors.black, child: _mediaViewWidget),
      Positioned(
          child: SizedBox(
        child: _pause
            ? Center(
                child: SizedBox(
                  width: ScreenUtil().setWidth(100),
                  height: ScreenUtil().setWidth(100),
                  child: const Icon(Icons.pause_circle_outlined,
                      size: 64, color: Colors.white),
                ),
              )
            : null,
      )),
    ]);
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
          color: Colors.black,
          child: _isStartPlay && !_isMyStartPlay
              ? getViewPlayWidget()
              : getNotStartPlayWidget(),
        ));
  }
}
