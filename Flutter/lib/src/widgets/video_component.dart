import 'package:rtcsdk/rtcsdk.dart';
import 'package:flutter/material.dart';

class VideoComponent extends StatefulWidget {
  final UsrVideoId usrVideoId;

  const VideoComponent({Key? key, required this.usrVideoId}) : super(key: key);

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
      videoComponent = RtcSDK.videoManager.createView((int vid) {
        viewID = vid;
        RtcSDK.videoManager.setUsrVideoId(vid, widget.usrVideoId);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: videoComponent,
    );
  }
}
