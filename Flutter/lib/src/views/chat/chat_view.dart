import 'package:rtcsdk_demo/src/controller/app_controller.dart';
import 'package:rtcsdk_demo/src/models/custom_msg.dart';
import 'package:rtcsdk_demo/src/widgets/custom_appbar.dart';
import 'package:rtcsdk_demo/src/widgets/custom_text_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rtcsdk_demo/src/resources/styles.dart';
import 'package:get/get.dart';
import 'chat_logic.dart';

class Chat extends StatelessWidget {
  Chat({Key? key}) : super(key: key);
  final appLogic = Get.find<AppController>();
  final logic = Get.find<ChatLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(title: "房间号：${logic.confId}"),
        body: Column(children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                controller: logic.scrollController,
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.all(15.w),
                itemBuilder: (BuildContext context, int index) {
                  CustomMsg msg = logic.lists[index];
                  bool isMySend = logic.isMySend(index);
                  return isMySend
                      ? rightItem(nickname: msg.fromUserID, text: msg.text)
                      : leftItem(nickname: msg.fromUserID, text: msg.text);
                },
                itemCount: logic.lists.length,
              ),
            ),
          ),
          Container(
            height: 42.h,
            // color: PageStyle.cf0f0f0,
            color: PageStyle.cffffff,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Row(
              children: [
                Expanded(
                    child: SizedBox(
                  height: 30.h,
                  child: CustomTextFormField(controller: logic.chatController),
                )),
                Container(
                  width: 70.w,
                  height: 30.h,
                  margin: EdgeInsets.only(left: 10.w),
                  child: ElevatedButton(
                      style: PageStyle.getButtonStyle(),
                      onPressed: logic.send,
                      child: Text(
                        "发送",
                        style: PageStyle.ts_14cffffff,
                      )),
                )
              ],
            ),
          )
        ]));
  }

  Widget leftItem({
    required String nickname,
    required String text,
  }) {
    String time = DateTime.now().toString().substring(11, 16);
    return Container(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "$time  ",
                  style: PageStyle.ts_14c666666,
                ),
                TextSpan(
                  text: nickname,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: const Color(0xff666666),
                  ),
                ),
              ],
            ),
          ),
          Container(
              padding: EdgeInsets.only(top: 10.h),
              child: Text(
                text,
                style: PageStyle.ts_14c333333,
              )),
        ],
      ),
    );
  }

  Widget rightItem({
    required String nickname,
    required String text,
  }) {
    String time = DateTime.now().toString().substring(11, 16);
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            time,
            style: PageStyle.ts_14c666666,
          ),
          Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: Text(
                text,
                textAlign: TextAlign.right,
                style: PageStyle.ts_14c333333,
              )),
        ],
      ),
    );
  }
}
