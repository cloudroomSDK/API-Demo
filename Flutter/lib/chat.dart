import 'dart:async';
import 'dart:convert';

import 'package:cloudroomvideosdk/cloudroomvideosdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'application/application.dart';

import 'application/common_func.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> with CrSDKNotifier, CommonFunc {
  String userId = GlobalConfig.instance.userID;
  int? confId = GlobalConfig.instance.confID;
  String nickName = GlobalConfig.instance.nickName;
  late TextEditingController _chatController;
  late ScrollController _scrollController;

  final List<CrChatMsg> _chatMsg = [];

  @override
  void initState() {
    _chatController = TextEditingController();
    _scrollController = ScrollController();
    addCrNotifierListener([
      NOTIFIER_EVENT.lineOff,
      NOTIFIER_EVENT.meetingDropped,
      NOTIFIER_EVENT.notifyMeetingCustomMsg
    ]);
    initPage(confId);
    super.initState();
  }

  @override
  void dispose() {
    disposeCrNotifierListener();
    _chatController.dispose();
    _scrollController.dispose();
    CrSDK.instance.exitMeeting();
    CrSDK.instance.logout();
    super.dispose();
  }

  @override
  lineOff(int sdkErr) {
    toHomePage();
  }

  @override
  meetingDropped(CR_MEETING_DROPPED_REASON reason) {
    commonMeetingDropped(reason);
  }

  @override
  toHomePage() {
    Duration transitionDuration = const Duration(milliseconds: 0);
    Application.router.navigateTo(context, "/",
        replace: true,
        transitionDuration: transitionDuration,
        clearStack: true);
  }

  @override
  notifyMeetingCustomMsg(CrChatMsg msg) {
    Map message = json.decode(msg.text);
    // 兼容云屋其它SDK端的约定格式
    if (message.containsKey("CmdType") && message["CmdType"] == "IM") {
      final CrChatMsg crmsg = CrChatMsg(msg.fromUserID, message["IMMsg"]);
      setState(() {
        _chatMsg.add(crmsg);
      });
      // 滚到最底部
      Timer(const Duration(milliseconds: 10), () {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200), curve: Curves.ease);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("房间号：$confId"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: toHomePage,
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xff1D232F),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  color: CrColors.backgroundColor,
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      controller: _scrollController,
                      padding: const EdgeInsets.all(15.0),
                      itemCount: _chatMsg.length,
                      itemBuilder: (BuildContext context, int index) {
                        CrChatMsg item = _chatMsg[index];
                        DateTime n = DateTime.now();
                        final String time = n.toString().substring(11, 16);
                        final bool isMySelf = item.fromUserID == userId;
                        final textDirection =
                            isMySelf ? TextDirection.rtl : TextDirection.ltr;
                        List<Widget> userInfo = [
                          Text("$time  ",
                              textDirection: textDirection,
                              style: const TextStyle(
                                  color: CrColors.textRegular, height: 1.1)),
                        ];
                        if (!isMySelf) {
                          userInfo.add(Text("${item.fromUserID}：",
                              textDirection: textDirection,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, height: 1.1)));
                        }

                        return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    width: ScreenUtil().screenWidth,
                                    child: Row(
                                        mainAxisAlignment: isMySelf
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                        children: userInfo)),
                                Container(
                                    width: ScreenUtil().screenWidth,
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      item.text,
                                      textAlign: isMySelf
                                          ? TextAlign.right
                                          : TextAlign.left,
                                      style: const TextStyle(
                                          height: 1.1,
                                          color: CrColors.textPrimary),
                                    )),
                              ],
                            ));
                      }),
                ),
              ),
              Container(
                width: double.infinity,
                height: ScreenUtil().setHeight(42),
                color: const Color(0xffF0F0F0),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                        child: SizedBox(
                            height: ScreenUtil().setHeight(30),
                            child: TextFormField(
                                controller: _chatController,
                                style: const TextStyle(
                                    color: CrColors.textPrimary),
                                cursorColor: CrColors.textPrimary,
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
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
                                        color: CrColors.borderColor,
                                      ),
                                    ))))),
                    Container(
                      width: ScreenUtil().setWidth(70),
                      height: ScreenUtil().setHeight(30),
                      margin: const EdgeInsets.only(left: 10),
                      child: ElevatedButton(
                          child: const Text("发送"),
                          style: ButtonStyle(
                            textStyle: MaterialStateProperty.all(
                                TextStyle(fontSize: ScreenUtil().setSp(14))),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0))),
                          ),
                          onPressed: () {
                            final text = _chatController.text.trim().toString();
                            if (text.isNotEmpty) {
                              String textJson = json.encode({
                                "CmdType": "IM",
                                "IMMsg": text,
                              });
                              CrSDK.instance
                                  .sendMeetingCustomMsg(textJson)
                                  .then((int sdkErr) {
                                if (sdkErr == 0) {
                                  setState(() {
                                    _chatController.text = "";
                                  });
                                } else {
                                  CrErrorDef error = CrErrorDef(sdkErr);
                                  EasyLoading.showToast(error.message);
                                }
                              });
                            }
                          }),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
