import 'dart:async';
import 'dart:convert';

import 'package:rtcsdk_demo/src/controller/app_controller.dart';
import 'package:rtcsdk_demo/src/controller/rtc_controller.dart';
import 'package:rtcsdk/rtcsdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:rtcsdk_demo/src/models/custom_msg.dart';
import 'package:rtcsdk_demo/src/models/error_def.dart';

class ChatLogic extends GetxController {
  final appLogic = Get.find<AppController>();
  final rtcLogic = Get.find<RTCController>();
  final String confId = Get.arguments['confId'];
  ScrollController scrollController = ScrollController();
  TextEditingController chatController = TextEditingController();
  List lists = [].obs;

  StreamSubscription<CustomMsg>? onNotifyMeetingCustomMsgSub;

  @override
  onInit() {
    onNotifyMeetingCustomMsgSub =
        rtcLogic.onNotifyMeetingCustomMsg.listen(newMessage);
    super.onInit();
  }

  @override
  onClose() {
    rtcLogic.exitMeeting();
    scrollController.dispose();
    chatController.dispose();
    onNotifyMeetingCustomMsgSub?.cancel();
    super.onClose();
  }

  send() async {
    final text = chatController.text.trim().toString();
    if (text.isNotEmpty) {
      String textJson = json.encode({
        "CmdType": "IM",
        "IMMsg": text,
      });
      int sdkErr = await RtcSDK.roomManager.sendMeetingCustomMsg(textJson);
      if (sdkErr == 0) {
        chatController.text = "";
      } else {
        EasyLoading.showToast(ErrorDef.getMessage(sdkErr));
      }
    }
  }

  newMessage(CustomMsg msg) {
    Map message = json.decode(msg.text);
    // 兼容其它SDK APIDEMO的约定格式
    if (message.containsKey("CmdType") && message["CmdType"] == "IM") {
      final CustomMsg crmsg = CustomMsg(msg.fromUserID, message["IMMsg"]);
      lists.add(crmsg);
      // 滚到最底部
      Timer(const Duration(milliseconds: 10), () {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.ease,
        );
      });
    }
  }

  bool isMySend(int index) {
    CustomMsg msg = lists[index];
    return msg.fromUserID == rtcLogic.userID;
  }
}
