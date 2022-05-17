import 'dart:convert';
import 'package:cloudroomvideosdk/cloudroomvideosdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'application/connectivitys.dart';
import 'application/application.dart';
import 'package:crypto/crypto.dart';

// ignore: must_be_immutable
class JoinRoom extends StatefulWidget {
  // 是否屏幕共享页面
  String target;

  JoinRoom({Key? key, required this.target}) : super(key: key);

  @override
  _JoinRoomState createState() => _JoinRoomState();
}

class _JoinRoomState extends State<JoinRoom> with Connectivitys {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _confIdController;

  double _cHeight = 320;
  List<Widget> _tips = [];
  bool _isDisabled = true;

  @override
  void initState() {
    int? confID = GlobalConfig.instance.confID;
    if (confID != null) {
      _confIdController = TextEditingController(text: confID.toString());
    } else {
      _confIdController = TextEditingController();
    }
    connectivityInit();
    _setPageWidget();
    super.initState();
  }

  @override
  void dispose() {
    _confIdController.dispose();
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

  void _setPageWidget() {
    // 屏幕共享
    if (widget.target == "screensharing") {
      _cHeight = 360;
      _tips = [
        Padding(
            padding: EdgeInsets.only(
                top: ScreenUtil().setHeight(25),
                bottom: ScreenUtil().setHeight(5)),
            child: const Text("1、“进入房间”默认角色为“观看端”",
                style: TextStyle(color: CrColors.textRegular))),
        const Text("2、“创建房间”默认角色为“共享端”",
            style: TextStyle(color: CrColors.textRegular)),
      ];
    }
  }

  Future<int> login() {
    final String nickName = GlobalConfig.instance.nickName;
    final String appID = GlobalConfig.instance.appId;
    final Digest digest =
        md5.convert(utf8.encode(GlobalConfig.instance.appSecret));
    final String appSecret = digest.toString();
    CrLoginDat config = CrLoginDat(
        nickName: nickName,
        privAcnt: nickName,
        appID: appID,
        appSecret: appSecret);
    return CrSDK.instance.login(config).then((CrLoginResult result) {
      if (result.sdkErr == 0) {
        GlobalConfig.instance.nickName = nickName;
        GlobalConfig.instance.userID = result.userID;
        GlobalConfig.instance.loginStatus = LOGIN_STATUS.login;
        Application.emit("changeLoginStatus");
      } else {
        CrErrorDef error = CrErrorDef(result.sdkErr);
        EasyLoading.showToast(error.message);
      }
      return result.sdkErr;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("加入房间"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              Application.router.pop(context);
            },
          ),
        ),
        body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode()); // 触摸收起键盘
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.only(top: ScreenUtil().setHeight(11)),
              color: CrColors.backgroundColor,
              child: SingleChildScrollView(
                  child: Column(children: [
                Container(
                  width: double.infinity,
                  height: ScreenUtil().setHeight(_cHeight),
                  color: Colors.white,
                  padding: EdgeInsets.only(
                      top: ScreenUtil().setHeight(28.5),
                      left: ScreenUtil().setWidth(27),
                      right: ScreenUtil().setWidth(27)),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(
                                bottom: ScreenUtil().setHeight(10)),
                            child: const Text("请输入房间号：",
                                style: TextStyle(color: CrColors.textPrimary))),
                        SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              controller: _confIdController,
                              style: const TextStyle(
                                  color: CrColors.textRegular), // 输入的样式
                              cursorColor: CrColors.primary,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp('[0-9]'))
                              ],
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(
                                    ScreenUtil().setWidth(15),
                                    ScreenUtil().setHeight(8),
                                    ScreenUtil().setWidth(15),
                                    ScreenUtil().setHeight(8)),
                                floatingLabelBehavior: FloatingLabelBehavior
                                    .always, // labelText的浮动状态
                                enabledBorder: const OutlineInputBorder(
                                  //未选中时候的颜色
                                  // borderRadius: BorderRadius.circular(32.0),
                                  borderSide: BorderSide(
                                    color: CrColors.borderColor,
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  //选中时外边框颜色
                                  borderSide: BorderSide(
                                    color: CrColors.primary,
                                  ),
                                ),
                                errorBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                                focusedErrorBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == "") {
                                  return "请输入房间号";
                                } else if (value?.length != 8) {
                                  return "请输入8位数字的房间号";
                                }
                                return null;
                              },
                            )),
                        // 进入房间按钮
                        Container(
                          margin: EdgeInsets.only(
                              top: ScreenUtil().setHeight(28.5)),
                          width: double.infinity,
                          height: ScreenUtil().setHeight(40),
                          child: ElevatedButton(
                              child: Text("进入房间",
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(16))),
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0))),
                              ),
                              onPressed: _isDisabled
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        EasyLoading.show(status: "进入房间");
                                        login().then((int sdkErr) {
                                          if (sdkErr != 0) return;
                                          final meetID = int.parse(
                                              _confIdController.text.trim());
                                          GlobalConfig.instance.confID = meetID;
                                          final String target =
                                              "/${widget.target}";
                                          Application.router.navigateTo(
                                              context, target,
                                              replace: true);
                                        });
                                      }
                                    }),
                        ),
                        // 分割线
                        Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 20, bottom: 20),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: ScreenUtil().setWidth(125),
                                    height: 1,
                                    child: const DecoratedBox(
                                      decoration:
                                          BoxDecoration(color: Colors.grey),
                                    ),
                                  ),
                                  const SizedBox(
                                    child: Text("或者",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: CrColors.textSecondary)),
                                  ),
                                  SizedBox(
                                    width: ScreenUtil().setWidth(125),
                                    height: 1,
                                    child: const DecoratedBox(
                                      decoration:
                                          BoxDecoration(color: Colors.grey),
                                    ),
                                  ),
                                ])),
                        // 创建房间按钮
                        SizedBox(
                          width: double.infinity,
                          height: ScreenUtil().setHeight(40),
                          child: OutlinedButton(
                              child: const Text("创建房间"),
                              style: ButtonStyle(
                                textStyle: MaterialStateProperty.all(TextStyle(
                                    fontSize: ScreenUtil().setSp(16))),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0))),
                                side: MaterialStateProperty.all(
                                    const BorderSide(color: Color(0xff329EF4))),
                              ),
                              onPressed: _isDisabled
                                  ? null
                                  : () {
                                      EasyLoading.showToast('创建房间');
                                      login().then((int sdkErr) {
                                        if (sdkErr != 0) return;
                                        final String target =
                                            "/${widget.target}";
                                        CrSDK.instance
                                            .createMeeting()
                                            .then((CrMeetInfo meetInfo) {
                                          if (meetInfo.sdkErr == 0) {
                                            GlobalConfig.instance.confID =
                                                meetInfo.confId;
                                            Application.router.navigateTo(
                                                context, target,
                                                replace: true);
                                          } else {
                                            CrErrorDef error =
                                                CrErrorDef(meetInfo.sdkErr);
                                            EasyLoading.showToast(
                                                error.message);
                                          }
                                        });
                                      });
                                    }),
                        ),
                        ..._tips
                      ],
                    ),
                  ),
                ),
              ])),
            )));
  }
}
