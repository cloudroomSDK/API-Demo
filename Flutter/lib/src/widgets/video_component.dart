import 'package:rtcsdk/rtcsdk.dart';
import 'package:flutter/material.dart';

class VideoComponent extends StatefulWidget {
  final UsrVideoId usrVideoId;
  final Function()? onTap;
  final Function(int viewID)? onViewID;
  final int? qualityLv; // 大流1，小流2

  const VideoComponent({
    Key? key,
    required this.usrVideoId,
    this.onTap,
    this.onViewID,
    this.qualityLv,
  }) : super(key: key);

  @override
  State<VideoComponent> createState() => VideoComponentState();
}

class VideoComponentState extends State<VideoComponent> {
  int? viewID;
  Widget? videoComponent;

  @override
  void initState() {
    createComponent();
    super.initState();
  }

  @override
  void dispose() {
    RtcSDK.videoManager.destroyPlatformView(viewID!);
    super.dispose();
  }

  void createComponent() {
    setState(() {
      videoComponent = RtcSDK.videoManager.createView((int vid) async {
        viewID = vid;
        await RtcSDK.videoManager.setUsrVideoId(vid, widget.usrVideoId,
            qualityLv: widget.qualityLv ?? 1);
        widget.onViewID?.call(vid);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // return GestureDetector(
    //   onTap: widget.onTap,
    //   child: Container(child: videoComponent),
    // );
    return Container(child: videoComponent);
  }
}
