import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:crypto/crypto.dart';
import 'application/application.dart';

import 'package:cloudroomvideosdk/cloudroomvideosdk.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  SettingState createState() => SettingState();
}

class SettingState extends State<Setting> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // late TextEditingController _nicknameController;
  late TextEditingController _serverAddrController;
  late TextEditingController _appIdController;
  late TextEditingController _appSecretController;

  final GlobalConfig _instance = GlobalConfig();

  @override
  void initState() {
    // _nicknameController = TextEditingController(text: _instance.nickName);
    _serverAddrController = TextEditingController(text: _instance.serverAddr);
    _appIdController = TextEditingController(text: _instance.appId);
    _appSecretController = TextEditingController(text: _instance.appSecret);
    super.initState();
  }

  @override
  void dispose() {
    // _nicknameController.dispose();
    _serverAddrController.dispose();
    _appIdController.dispose();
    _appSecretController.dispose();
    super.dispose();
  }

  // sdkLogin(context) async {
  //   if (GlobalConfig.instance.loginStatus == LOGIN_STATUS.login) {
  //     await CrSDK.instance.logout();
  //   }
  //   EasyLoading.showToast('登录');
  //   await CrSDK.instance.setServerAddr(GlobalConfig.instance.serverAddr);
  //   final String nickName = GlobalConfig.instance.nickName;
  //   final String privAcnt = GlobalConfig.instance.nickName;
  //   final String appID = GlobalConfig.instance.appId;
  //   final Digest digest =
  //       md5.convert(utf8.encode(GlobalConfig.instance.appSecret));
  //   final String appSecret = digest.toString();
  //   CrLoginDat config = CrLoginDat(
  //       nickName: nickName,
  //       privAcnt: privAcnt,
  //       appID: appID,
  //       appSecret: appSecret);

  //   CrSDK.instance.login(config).then((CrLoginResult result) {
  //     if (result.sdkErr == 0) {
  //       EasyLoading.showToast("保存设置成功！");
  //       GlobalConfig.instance.nickName = nickName;
  //       GlobalConfig.instance.userID = result.userID;
  //       GlobalConfig.instance.loginStatus = LOGIN_STATUS.login;
  //       Application.emit("changeLoginStatus");
  //       Application.router.pop(context);
  //     } else {
  //       CrErrorDef error = CrErrorDef(result.sdkErr);
  //       EasyLoading.showToast(error.message);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("设置"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              Application.router.pop(context);
            },
          ),
          actions: [
            TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _instance.serverAddr = _serverAddrController.text.trim();
                    _instance.appId = _appIdController.text.trim();
                    _instance.appSecret = _appSecretController.text.trim();
                    // final String _nickName = _nicknameController.text.trim();
                    // if (_instance.nickName != _nickName) {
                    //   await CrSDK.instance.setNickName(
                    //       GlobalConfig.instance.userID, _nickName);
                    //   _instance.nickName = _nickName;
                    // }
                    // sdkLogin(context);
                    CrSDK.instance
                        .setServerAddr(GlobalConfig.instance.serverAddr);
                    EasyLoading.showToast("保存设置成功！");
                    Application.router.pop(context);
                  }
                },
                child: const Text("保存"))
          ],
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
                  color: Colors.white,
                  padding: EdgeInsets.only(
                      top: ScreenUtil().setHeight(28.5),
                      left: ScreenUtil().setWidth(27),
                      right: ScreenUtil().setWidth(27),
                      bottom: ScreenUtil().setHeight(28.5)),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(
                                bottom: ScreenUtil().setHeight(10)),
                            child: const Text("服务器地址：",
                                style: TextStyle(color: CrColors.textPrimary))),
                        SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              controller: _serverAddrController,
                              style: const TextStyle(
                                  color: CrColors.textRegular), // 输入的样式
                              cursorColor: CrColors.primary,
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
                                if (value!.isEmpty) {
                                  return "请输入服务器地址";
                                }
                                return null;
                              },
                            )),
                        Padding(
                            padding: EdgeInsets.only(
                                top: ScreenUtil().setHeight(24),
                                bottom: ScreenUtil().setHeight(10)),
                            child: const Text("APP ID :",
                                style: TextStyle(color: CrColors.textPrimary))),
                        SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              controller: _appIdController,
                              style:
                                  const TextStyle(color: CrColors.textRegular),
                              cursorColor: CrColors.primary,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(
                                    ScreenUtil().setWidth(15),
                                    ScreenUtil().setHeight(8),
                                    ScreenUtil().setWidth(15),
                                    ScreenUtil().setHeight(8)),
                                enabledBorder: const OutlineInputBorder(
                                  //未选中时候的颜色
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
                                if (value!.isEmpty) {
                                  return "请输入APPID";
                                }
                                return null;
                              },
                            )),
                        Padding(
                            padding: EdgeInsets.only(
                                top: ScreenUtil().setHeight(24),
                                bottom: ScreenUtil().setHeight(10)),
                            child: const Text("APP Secret :",
                                style: TextStyle(color: CrColors.textPrimary))),
                        SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              controller: _appSecretController,
                              obscureText: true, // 输入框内容是否掩码
                              style: const TextStyle(
                                  color: CrColors.textRegular), // 输入的样式
                              cursorColor: CrColors.primary,
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
                                if (value!.isEmpty) {
                                  return "请输入APP Secret";
                                }
                                return null;
                              },
                            )),
                        // Padding(
                        //     padding: EdgeInsets.only(
                        //         top: ScreenUtil().setHeight(24),
                        //         bottom: ScreenUtil().setHeight(10)),
                        //     child: const Text("昵称 :",
                        //         style: TextStyle(color: CrColors.textPrimary))),
                        // SizedBox(
                        //     width: double.infinity,
                        //     child: TextFormField(
                        //       controller: _nicknameController,
                        //       style: const TextStyle(
                        //           color: CrColors.textRegular), // 输入的样式
                        //       cursorColor: CrColors.primary,
                        //       decoration: InputDecoration(
                        //         contentPadding: EdgeInsets.fromLTRB(
                        //             ScreenUtil().setWidth(15),
                        //             ScreenUtil().setHeight(8),
                        //             ScreenUtil().setWidth(15),
                        //             ScreenUtil().setHeight(8)),
                        //         floatingLabelBehavior: FloatingLabelBehavior
                        //             .always, // labelText的浮动状态
                        //         enabledBorder: const OutlineInputBorder(
                        //           //未选中时候的颜色
                        //           borderSide: BorderSide(
                        //             color: CrColors.borderColor,
                        //           ),
                        //         ),
                        //         focusedBorder: const OutlineInputBorder(
                        //           //选中时外边框颜色
                        //           borderSide: BorderSide(
                        //             color: CrColors.primary,
                        //           ),
                        //         ),
                        //         errorBorder: const OutlineInputBorder(
                        //           borderSide: BorderSide(
                        //             color: Colors.red,
                        //           ),
                        //         ),
                        //         focusedErrorBorder: const OutlineInputBorder(
                        //           borderSide: BorderSide(
                        //             color: Colors.red,
                        //           ),
                        //         ),
                        //       ),
                        //       validator: (value) {
                        //         if (value!.isEmpty) {
                        //           return "请输入昵称";
                        //         }
                        //         return null;
                        //       },
                        //     ))
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: ScreenUtil().setHeight(45)),
                  padding: EdgeInsets.only(
                      left: ScreenUtil().setWidth(27),
                      right: ScreenUtil().setWidth(27)),
                  width: double.infinity,
                  height: ScreenUtil().setHeight(40),
                  child: ElevatedButton(
                      child: const Text("恢复默认"),
                      style: ButtonStyle(
                        textStyle: MaterialStateProperty.all(
                            TextStyle(fontSize: ScreenUtil().setSp(16))),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            // side: BorderSide.none,
                            borderRadius: BorderRadius.circular(5.0))),
                      ),
                      onPressed: () async {
                        _instance.resetDefaultSetting();
                        setState(() {
                          _serverAddrController.text = _instance.serverAddr;
                          _appIdController.text = _instance.appId;
                          _appSecretController.text = _instance.appSecret;
                        });
                        EasyLoading.showToast("恢复默认设置");
                      }),
                ),
              ])),
            )));
  }
}
