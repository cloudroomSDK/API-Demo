import 'package:rtcsdk/rtcsdk.dart';
import 'package:flutter/material.dart';

class MediaComponent extends StatefulWidget {
  const MediaComponent({
    Key? key,
  }) : super(key: key);

  @override
  State<MediaComponent> createState() => MediaComponentState();
}

class MediaComponentState extends State<MediaComponent> {
  int? viewID;
  Widget? mediaComponent;

  @override
  void initState() {
    createComponent();
    super.initState();
  }

  @override
  void dispose() {
    RtcSDK.mediaManager.destroyPlatformView(viewID!);
    super.dispose();
  }

  void createComponent() {
    setState(() {
      mediaComponent = RtcSDK.mediaManager.createView((int vID) {
        viewID = vID;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: mediaComponent,
    );
  }
}
