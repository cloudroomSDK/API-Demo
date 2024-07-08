import 'package:rtcsdk/rtcsdk.dart';
import 'package:flutter/material.dart';
import 'package:rtcsdk_demo/src/models/video_position.dart';
import 'package:rtcsdk_demo/src/utils/logger_util.dart';

import 'video_component.dart';

class VideoComponentLayoutController extends ChangeNotifier {
  VideoComponentLayoutController();

  update() {
    notifyListeners();
  }
}

class VideoComponentLayout extends StatefulWidget {
  final UsrVideoId mainUsrVideoId;
  final VideoComponentLayoutController? controller;

  const VideoComponentLayout({
    Key? key,
    required this.mainUsrVideoId,
    this.controller,
  }) : super(key: key);

  @override
  State<VideoComponentLayout> createState() => VideoComponentLayoutState();
}

class VideoComponentLayoutState extends State<VideoComponentLayout> {
  List<VideoPosition> vps = [];
  List<Widget> videoComponents = [];
  List<Widget> children = [];

  // 计算小视频位置 vNum（竖着的个数） hNum（横着的个数）
  List<VideoPosition> getVideoPosition(
      {required BuildContext ctx, int vNum = 3, int hNum = 3}) {
    int maxVideoNum = vNum * hNum;
    double padding = 100;
    double screenWidth = MediaQuery.of(ctx).size.width;
    double screenHeight = MediaQuery.of(ctx).size.height;
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
    return List.generate(maxVideoNum, (index) {
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
  }

  Future<void> getWatchableVideos() async {
    List<UsrVideoId> usrVideoIds =
        await RtcSDK.videoManager.getWatchableVideos();
    for (var item in usrVideoIds) {
      Logger.log('usrVideoIds: ${item.userId} __ ${item.videoID}');
    }

    List<Widget> smallVComponents = [];
    for (int i = 0; i < usrVideoIds.length; i++) {
      if (smallVComponents.length == 9) break;
      UsrVideoId item = usrVideoIds[i];
      VideoPosition vp = vps[i];
      if (item.userId != widget.mainUsrVideoId.userId) {
        smallVComponents.add(
          Positioned(
            left: vp.left,
            top: vp.top,
            width: vp.width,
            height: vp.height,
            child: VideoComponent(
              key: Key('${item.userId}_${item.videoID}'),
              usrVideoId: item,
            ),
          ),
        );
      }
    }

    setState(() {
      videoComponents = smallVComponents;
    });
  }

  @override
  void initState() {
    widget.controller?.addListener(getWatchableVideos);
    vps = getVideoPosition(ctx: context);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller?.removeListener(getWatchableVideos);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [
      VideoComponent(
        usrVideoId: widget.mainUsrVideoId,
      )
    ];
    widgets.addAll(videoComponents);
    widgets.addAll(children);
    return Stack(children: widgets);
  }
}
