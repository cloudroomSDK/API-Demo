import 'package:rtcsdk/rtcsdk.dart';
import 'package:flutter/material.dart';

class ShareComponent extends StatefulWidget {
  const ShareComponent({
    Key? key,
  }) : super(key: key);

  @override
  State<ShareComponent> createState() => ShareComponentState();
}

class ShareComponentState extends State<ShareComponent> {
  int? viewID;
  Widget? shareComponent;

  @override
  void initState() {
    createComponent();
    super.initState();
  }

  @override
  void dispose() {
    RtcSDK.screenShareManager.destroyPlatformView(viewID!);
    super.dispose();
  }

  void createComponent() {
    setState(() {
      shareComponent = RtcSDK.screenShareManager.createView((int vID) {
        viewID = vID;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: shareComponent,
    );
  }
}
