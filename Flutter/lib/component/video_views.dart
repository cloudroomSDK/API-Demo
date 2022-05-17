import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloudroomvideosdk/cloudroomvideosdk.dart';
import 'package:cloudroomvideosdk_example/application/application.dart';

class ViewInfo {
  String label = "";
  CrUsrVideoId? usrVideoId;
  int? viewId;
  Widget? view;
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

// ignore: must_be_immutable
class VideoViews extends StatefulWidget {
  Function? updateMyVideoCallback;
  Function? updateVideosCallback;
  Function? updateDefaultCameraInfoCallback;
  VideoViews(
      {Key? key,
      this.updateMyVideoCallback,
      this.updateVideosCallback,
      this.updateDefaultCameraInfoCallback})
      : super(key: key);

  @override
  VideoViewsState createState() => VideoViewsState();
}

class VideoViewsState extends State<VideoViews> with CrSDKNotifier {
  String userId = GlobalConfig.instance.userID;
  int? confId = GlobalConfig.instance.confID;
  String nickName = GlobalConfig.instance.nickName;
  // 视频的摆放位置
  final List<VideoPosition> _videoPosition = [];

  // 自己的视频的信息
  ViewInfo? _myViewInfo;
  // 小视频的信息
  final List<ViewInfo> _viewsinfo = [];
  // 小视频最大个数
  int _maxVideoNum = 9;
  List<Widget> _videos = [];

  ViewInfo? get myViewInfo => _myViewInfo;
  List<ViewInfo> get viewsinfo =>
      _viewsinfo.where((e) => e.usrVideoId != null).toList();
  List<VideoPosition> get videoPosition => _videoPosition;

  int _speakerVolume = 0;
  List<CrCameraInfo> _camerasInfo = [];

  CrCameraInfo? _defaultCameraInfo;
  CrCameraInfo? get defaultCameraInfo => _defaultCameraInfo;

  @override
  void initState() {
    addCrNotifierListener([
      NOTIFIER_EVENT.userLeftMeeting,
      NOTIFIER_EVENT.videoStatusChanged,
      NOTIFIER_EVENT.videoDevChanged,
    ]);
    // 初始化小视频的摆放位置
    initCalcVideoPosition();
    getDefaultVideo(userId).then((_) {
      // 获取的摄像头不是前置摄像头就改成前置摄像头
      if (_defaultCameraInfo?.cameraPosition != CR_CAMERA_POSITION.FRONT) {
        setDefaultVideo(CR_CAMERA_POSITION.FRONT);
      }
    });
    setMyVideo(userId);
    getWatchableVideos();
    getSpeakerVolume();
    super.initState();
  }

  @override
  void dispose() {
    disposeCrNotifierListener();
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

  @override
  void userLeftMeeting(String userID) {
    updateWatchableVideos(userID);
  }

  // 监听状态变化
  @override
  void videoStatusChanged(CrVideoStatusChanged vsc) {
    String userID = vsc.userId;
    if (userID != userId &&
        (vsc.newStatus == CR_VSTATUS.VOPEN ||
            vsc.newStatus == CR_VSTATUS.VCLOSE)) {
      updateWatchableVideos(userID);
    }
  }

  // 监听设备变化
  @override
  void videoDevChanged(String userID) {
    if (userID != userId) {
      updateWatchableVideos(userID);
    }
  }

  // 更新
  void updateWatchableVideos(String userID) {
    Utils.debounce("getWatchableVideos", () {
      getWatchableVideos();
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

  // 获取用户所有的摄像头信息
  Future<List<CrCameraInfo>> getAllVideoInfo(String userId) {
    return CrSDK.instance.getAllVideoInfo(userId).then((camerasInfo) {
      _camerasInfo = camerasInfo;
      return camerasInfo;
    });
  }

  // 获取用户默认摄像头
  Future<int> getDefaultVideo(String userId) {
    return getAllVideoInfo(userId).then((List<CrCameraInfo> camerasInfo) {
      return CrSDK.instance.getDefaultVideo(userId).then((int videoID) {
        for (CrCameraInfo cInfo in camerasInfo) {
          if (cInfo.videoID == videoID) {
            _defaultCameraInfo = cInfo;
          }
        }
        return videoID;
      });
    });
  }

  // 切换前后摄像头
  void setDefaultVideo(CR_CAMERA_POSITION cameraPosition) {
    // 从摄像头信息中找到对应位置的摄像头
    for (int i = 0; i < _camerasInfo.length; i++) {
      CrCameraInfo item = _camerasInfo[i];
      if (item.cameraPosition == cameraPosition) {
        _defaultCameraInfo = item;
        CrSDK.instance.setDefaultVideo(userId, item.videoID);
        if (widget.updateDefaultCameraInfoCallback != null) {
          widget.updateDefaultCameraInfoCallback!(item);
        }
        break;
      }
    }
  }

  void setMyVideo(userID) {
    CrUsrVideoId usrVideoId = CrUsrVideoId(userId: userID, videoID: -1);
    ViewInfo myvi = ViewInfo();
    myvi.usrVideoId = usrVideoId;
    myvi.view = CrSDK.instance.createPlatformView((viewID) {
      myvi.viewId = viewID;
      CrSDK.instance.setUsrVideoId(viewID, usrVideoId);
    });
    setState(() {
      _myViewInfo = myvi;
    });
    if (widget.updateMyVideoCallback != null) {
      widget.updateMyVideoCallback!(myvi);
    }
  }

  // 获取房间内所有可观看的摄像头
  void getWatchableVideos() {
    CrSDK.instance.getWatchableVideos().then((List<CrUsrVideoId> usrVideoIds) {
      List<CrUsrVideoId> uvis = [];
      Map<String, int> uviCounts = {}; // 计算同个用户开的摄像头个数
      for (CrUsrVideoId uvi in usrVideoIds) {
        if (uvis.length >= _maxVideoNum) break;
        String cuid = uvi.userId;
        if (cuid != userId) {
          uviCounts.containsKey(cuid)
              ? uviCounts[cuid] = (uviCounts[cuid]! + 1)
              : uviCounts[cuid] = 1;
          uvis.add(uvi);
        }
      }

      for (ViewInfo vi in _viewsinfo) {
        vi.label = "";
        vi.usrVideoId = null;
      }

      for (int idx = 0; idx < uvis.length; idx++) {
        CrUsrVideoId uvi = uvis[idx];
        ViewInfo vInfo;
        if (_viewsinfo.length > idx) {
          vInfo = _viewsinfo[idx];
          vInfo.usrVideoId = uvi;
        } else {
          vInfo = ViewInfo();
          vInfo.usrVideoId = uvi;
          _viewsinfo.add(vInfo);
        }
        bool _isMore = uviCounts[uvi.userId]! > 1;
        vInfo.label = _isMore ? "${uvi.userId}-${uvi.videoID}" : uvi.userId;
        setUsrVideoId(vInfo);
      }
      updateVideos();
    });
  }

  void setUsrVideoId(ViewInfo uvi) {
    if (uvi.viewId != null) {
      CrSDK.instance
          .setUsrVideoId(uvi.viewId, uvi.usrVideoId!)
          .then((value) {})
          .catchError((err) {});
    } else {
      // 创建视图容器
      uvi.view = CrSDK.instance.createPlatformView((viewID) {
        uvi.viewId = viewID;
        CrSDK.instance.setUsrVideoId(viewID, uvi.usrVideoId!).then((value) {
          // CrSDK.instance.setScaleType(viewID, 1);
        }).catchError((err) {});
      });
    }
  }

  void updateVideos() {
    List<Widget> videos = [];
    for (int index = 0; index < _viewsinfo.length; index++) {
      ViewInfo viewInfo = _viewsinfo[index];
      if (viewInfo.usrVideoId != null) {
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
    }
    if (mounted) {
      setState(() {
        _videos = videos;
      });

      // 通知外部组件更新，用于录制界面
      if (widget.updateVideosCallback != null) {
        // _viewsinfo, _videoPosition
        widget.updateVideosCallback!();
      }
    }
  }

  destoryVideo() async {
    // 删除自己的视频的原生控件
    int? myViewId = _myViewInfo?.viewId;
    if (myViewId != null) {
      CrSDK.instance.destroyPlatformView(myViewId);
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
