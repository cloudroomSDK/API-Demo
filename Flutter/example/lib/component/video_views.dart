import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloudroomvideosdk/cloudroomvideosdk.dart';
import 'package:cloudroomvideosdk_example/application/application.dart';
import 'package:cloudroomvideosdk_example/application/utils.dart';

class ViewInfo {
  String userId;
  int? viewId;
  Widget? view;
  CrUsrVideoId usrVideoId;
  String label = "";
  ViewInfo(this.userId, this.usrVideoId);
}

class VideoPosition {
  double top;
  double left;
  double width;
  double height;
  double ptop;
  double pleft;
  double pwidth;
  double pheight;
  VideoPosition(
      {required this.top,
      required this.left,
      required this.width,
      required this.height,
      required this.ptop,
      required this.pleft,
      required this.pwidth,
      required this.pheight});
}

class VideoViews extends StatefulWidget {
  const VideoViews({Key? key}) : super(key: key);

  @override
  VideoViewsState createState() => VideoViewsState();
}

class VideoViewsState extends State<VideoViews> {
  String userId = GlobalConfig.instance.userID;
  int? confId = GlobalConfig.instance.confID;
  String nickName = GlobalConfig.instance.nickName;

  // 自己的视频的信息
  ViewInfo? _myViewInfo;
  // 小视频的摆放位置
  final List<VideoPosition> _videoPosition = [];
  // 小视频的信息
  final List<ViewInfo> _viewsinfo = [];
  // 小视频最大个数
  int _maxVideoNum = 9;
  List<Widget> _videos = [];

  ViewInfo? get myViewInfo => _myViewInfo;
  List<ViewInfo> get viewsinfo => _viewsinfo;
  List<VideoPosition> get videoPosition => _videoPosition;

  int _speakerVolume = 0;

  @override
  void initState() {
    CrSDK.on("videoStatusChanged", videoStatusChanged);
    CrSDK.on("videoDevChanged", videoDevChanged);
    // 初始化小视频的摆放位置
    initCalcVideoPosition();
    setMyVideo(userId);
    getWatchableVideos();
    getSpeakerVolume();
    super.initState();
  }

  @override
  void dispose() {
    CrSDK.off("videoStatusChanged", videoStatusChanged);
    CrSDK.off("videoDevChanged", videoDevChanged);
    destoryVideo();
    super.dispose();
  }

  void getSpeakerVolume() {
    CrSDK.instance.getSpeakerVolume().then((int vol) {
      _speakerVolume = vol;
    });
  }

  void setSpeakerVolume(int vol) {
    CrSDK.instance.setSpeakerVolume(vol).then((value) => _speakerVolume = vol);
  }

  // 监听状态变化
  void videoStatusChanged(CrVideoStatusChanged vsc) {
    String userID = vsc.userId;
    if (userID != userId &&
        (vsc.newStatus == CR_VSTATUS.VOPEN ||
            vsc.newStatus == CR_VSTATUS.VCLOSE)) {
      updateWatchableVideos(userID);
    }
  }

  // 监听设备变化
  void videoDevChanged(String userID) {
    if (userID != userId) {
      updateWatchableVideos(userID);
    }
  }

  // 更新
  void updateWatchableVideos(String userID) {
    removeVideo(userID);
    Utils.debounce("getWatchableVideos", () {
      getWatchableVideos(userID);
    });
  }

  // 需要限制不要超过vNum（竖着的个数） * hNum（横着的个数）个
  void initCalcVideoPosition([int vNum = 3, int hNum = 3]) {
    _maxVideoNum = vNum * hNum;
    double padding = 100;
    double screenWidth = ScreenUtil().screenWidth;
    double screenHeight = ScreenUtil().screenHeight;
    double gscreenWidth = screenWidth - padding;
    double gscreenHeight = screenHeight - padding;
    double height = gscreenHeight / vNum; // 小视频的高度
    double cwidth = height / 16 * 9; // 小视频根据高度算出来的宽度
    double width = gscreenWidth / hNum; // 小视频的宽度
    double cheight = width / 9 * 16; // 小视频根据宽度算出来的高度
    if (width > cwidth) {
      width = cwidth;
    } else {
      height = cheight;
    }
    double pwidth = width / screenWidth; // 宽度百分比
    double pheight = height / screenHeight; // 高度百分比
    int initialTop = 20; // 初始顶部距离
    int initialRight = 10; // 初始右边距离
    int gutterTop = 20; // 每个item的paddingTop
    int gutterRight = 20; // 每个item的paddingRight
    // 竖着从右到左排vNum * hNum个
    List<VideoPosition> videoPosition = List.generate(_maxVideoNum, (index) {
      final int idx = index + 1;
      final int tmod = index % vNum;
      double top = (height + gutterTop) * tmod + initialTop;
      double left = screenWidth -
          ((idx / hNum).ceil() * (width + gutterRight)) +
          (gutterRight - initialRight);
      double ptop = top / screenHeight;
      double pleft = left / screenWidth;

      return VideoPosition(
          top: top,
          left: left,
          height: height,
          width: width,
          pheight: pheight,
          pwidth: pwidth,
          ptop: ptop,
          pleft: pleft);
    });
    _videoPosition.addAll(videoPosition);
  }

  void setMyVideo(userID) {
    CrUsrVideoId usrVideoId = CrUsrVideoId(userId: userID, videoID: -1);
    _myViewInfo = ViewInfo(userID, usrVideoId);
    Widget? viewWidget = CrSDK.instance.createPlatformView((viewID) {
      _myViewInfo?.viewId = viewID;
      CrSDK.instance.setUsrVideoId(viewID, usrVideoId);
    });
    _myViewInfo?.view = viewWidget;
  }

  // 获取房间内所有可观看的摄像头
  void getWatchableVideos([String? targetUserId]) async {
    List<CrUsrVideoId> usrVideoIds = await CrSDK.instance.getWatchableVideos();
    if (targetUserId != null) {
      // 有指定userId用指定的
      List<CrUsrVideoId> tuvids =
          usrVideoIds.where((_uvids) => _uvids.userId == targetUserId).toList();
      bool _isMore = tuvids.length > 1;
      for (CrUsrVideoId fuvi in tuvids) {
        addVideo(fuvi, _isMore);
      }
    } else {
      Map<String, int> uviCounts = {};
      for (CrUsrVideoId uvi in usrVideoIds) {
        if (uviCounts.containsKey(uvi.userId)) {
          uviCounts[uvi.userId] = (uviCounts[uvi.userId]! + 1);
        } else {
          uviCounts[uvi.userId] = 1;
        }
      }
      for (CrUsrVideoId uvi in usrVideoIds) {
        if (uvi.userId != userId) {
          addVideo(uvi, uviCounts[uvi.userId]! > 1);
        }
      }
    }
    updateVideos();
  }

  void addVideo(CrUsrVideoId usrVideoId, [bool _isMore = false]) {
    if (_viewsinfo.length < _maxVideoNum) {
      ViewInfo smallVideoView = ViewInfo(usrVideoId.userId, usrVideoId);
      String label = _isMore
          ? "${usrVideoId.userId}-${usrVideoId.videoID}"
          : usrVideoId.userId;
      smallVideoView.label = label;
      String flag = DateTime.now().microsecondsSinceEpoch.toString();
      String valuekey = "$label$flag";
      // 创建视图容器
      smallVideoView.view = CrSDK.instance.createPlatformView((viewID) {
        smallVideoView.viewId = viewID;
        CrSDK.instance.setUsrVideoId(viewID, usrVideoId);
        // CrSDK.instance.setUsrVideoId(viewID, usrVideoId).then((value) {
        //   CrSDK.instance.setScaleType(viewID, 1);
        // });
      }, key: ValueKey(valuekey));
      _viewsinfo.add(smallVideoView);
    }
  }

  void updateVideos() {
    List<Widget> videos = [];
    for (int index = 0; index < _viewsinfo.length; index++) {
      ViewInfo viewInfo = _viewsinfo[index];
      Widget? view = viewInfo.view;
      VideoPosition position = _videoPosition[index];
      final Widget video = Positioned(
          top: position.top,
          left: position.left,
          child: Stack(children: [
            SizedBox(
              width: position.width,
              height: position.height,
              child: view,
            ),
            Positioned(
                left: 0,
                bottom: 0,
                child: SizedBox(
                  width: position.width,
                  child: Text(
                    viewInfo.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ))
          ]));
      videos.add(video);
    }

    if (mounted) {
      // 通知外部组件更新，用于录制界面
      CrSDK.emit("videoViewsUpdateVideos");

      setState(() {
        _videos = videos;
      });
    }
  }

  void removeVideo(String userID) {
    List<ViewInfo> waitRmViewInfo = [];
    for (int index = 0; index < _viewsinfo.length; index++) {
      ViewInfo vinfo = _viewsinfo[index];
      int? viewId = vinfo.viewId;
      if (vinfo.userId == userID && viewId != null) {
        waitRmViewInfo.add(vinfo);
      }
    }
    for (ViewInfo waitrminfo in waitRmViewInfo) {
      CrSDK.instance.destroyPlatformView(waitrminfo.viewId!);
      _viewsinfo.remove(waitrminfo);
    }
  }

  destoryVideo() async {
    // 删除自己的视频的原生控件
    int? myViewId = _myViewInfo?.viewId;
    if (myViewId != null) {
      CrSDK.instance.destroyPlatformView(myViewId);
      _myViewInfo = null;
    }
    // 删除其他视频的原生控件
    for (ViewInfo vinfo in _viewsinfo) {
      int? viewId = vinfo.viewId;
      if (viewId != null) {
        CrSDK.instance.destroyPlatformView(viewId);
      }
    }
    _viewsinfo.clear();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
        autofocus: true,
        focusNode: FocusNode(),
        onKey: (evt) {
          if (evt.runtimeType == RawKeyDownEvent) {
            int? keyCode;
            if (Platform.isAndroid) {
              RawKeyEventDataAndroid data = evt.data as RawKeyEventDataAndroid;
              keyCode = data.keyCode;
            } else if (Platform.isIOS) {
              RawKeyEventDataIos idata = evt.data as RawKeyEventDataIos;
              keyCode = idata.keyCode;
            }
            if (keyCode == 24 || keyCode == 25) {
              int vol = keyCode == 24
                  ? min(255, _speakerVolume + 15)
                  : max(0, _speakerVolume - 15);
              setSpeakerVolume(vol);
            }
          }
        },
        child: Stack(children: [
          SizedBox(
            child: _myViewInfo?.view,
          ),
          Positioned(
              top: 10,
              left: 10,
              child: Text(
                userId,
                style: const TextStyle(color: Colors.white),
              )),
          ..._videos
        ]));
  }
}
