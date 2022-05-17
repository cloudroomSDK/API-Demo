import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'application/application.dart';
import 'application/connectivitys.dart';

class ButtonProps {
  final String text;
  final String path;
  ButtonProps(this.text, this.path);
}

class Functions extends StatefulWidget {
  const Functions({Key? key}) : super(key: key);

  @override
  FunctionsState createState() => FunctionsState();
}

class FunctionsState extends State<Functions> with Connectivitys {
  String _version = "";
  final List<ButtonProps> basicButtonsConfig = [
    ButtonProps("语音通话", "/joinroom?target=audiochannel"),
    ButtonProps("视频通话", "/joinroom?target=videochannel"),
    ButtonProps("视频设置", "/joinroom?target=videoconfig"),
    ButtonProps("屏幕共享", "/joinroom?target=screensharing"),
  ];
  final List<ButtonProps> advancedButtonsConfig = [
    ButtonProps("本地录制", "/joinroom?target=localrecord"),
    ButtonProps("云端录制", "/joinroom?target=remoterecord"),
    ButtonProps("视频播放", "/joinroom?target=videoplayer"),
    ButtonProps("聊天", "/joinroom?target=chat"),
  ];

  bool _isDisabled = true;

  @override
  void initState() {
    connectivityInit();
    _initPackageInfo();
    super.initState();
  }

  @override
  void dispose() {
    connectivityDispose();
    super.dispose();
  }

  @override
  void connectivityConnect() {
    setState(() {
      _isDisabled = false;
    });
  }

  @override
  void connectivityDisconnect() {
    setState(() {
      _isDisabled = true;
    });
  }

  void _initPackageInfo() {
    PackageInfo.fromPlatform().then((PackageInfo info) => setState(() {
          _version = "版本号：${info.version}";
        }));
  }

  genertorButtonWidget(List<ButtonProps> configs) {
    return configs.map((btn) {
      return Container(
        margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(8.5)),
        width: double.infinity,
        height: ScreenUtil().setHeight(40),
        child: ElevatedButton(
            child: Text(btn.text,
                style: TextStyle(fontSize: ScreenUtil().setSp(14))),
            style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0))),
            ),
            onPressed: _isDisabled
                ? null
                : () {
                    Application.router.navigateTo(context, btn.path);
                  }),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("云屋API DEMO"),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: Color(0xff444444),
              ),
              onPressed: () {
                Application.router.navigateTo(context, "/setting");
              },
            )
          ],
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            Container(
                width: double.infinity,
                color: const Color(0xfff2f2f2),
                child: Padding(
                    padding: EdgeInsets.only(
                      left: ScreenUtil().setWidth(15.5),
                      top: ScreenUtil().setHeight(13.5),
                      bottom: ScreenUtil().setHeight(8.0),
                    ),
                    child: const Text(
                      "基础功能",
                      style: TextStyle(
                        color: CrColors.textSecondary,
                      ),
                    ))),
            Container(
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    ScreenUtil().setWidth(36.0),
                    ScreenUtil().setHeight(25.0),
                    ScreenUtil().setWidth(36.0),
                    ScreenUtil().setHeight(25.0)),
                child: Column(
                  children: genertorButtonWidget(basicButtonsConfig),
                ),
              ),
            ),
            Container(
                width: double.infinity,
                color: CrColors.backgroundColor,
                child: Padding(
                    padding: EdgeInsets.only(
                      left: ScreenUtil().setWidth(15.5),
                      top: ScreenUtil().setHeight(13.5),
                      bottom: ScreenUtil().setHeight(8.0),
                    ),
                    child: const Text(
                      "高级功能",
                      style: TextStyle(
                        color: CrColors.textSecondary,
                      ),
                    ))),
            Container(
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    ScreenUtil().setWidth(36.0),
                    ScreenUtil().setHeight(25.0),
                    ScreenUtil().setWidth(36.0),
                    ScreenUtil().setHeight(25.0)),
                child: Column(
                  children: genertorButtonWidget(advancedButtonsConfig),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(_version,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: CrColors.textRegular)),
            )
          ],
        )));
  }
}
