import 'package:rtcsdk_demo/src/controller/app_controller.dart';
import 'package:rtcsdk_demo/src/controller/rtc_controller.dart';
import 'package:rtcsdk_demo/src/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rtcsdk_demo/src/resources/styles.dart';
import 'package:rtcsdk_demo/src/extension/custom_ext.dart';
import 'package:get/get.dart';

import 'testing_logic.dart';

class Testing extends StatelessWidget {
  Testing({Key? key}) : super(key: key);
  final appLogic = Get.find<AppController>();
  final rtcLogic = Get.find<RTCController>();
  final logic = Get.find<TestingLogic>();

  Widget button(
    String text, {
    void Function()? onPressed,
  }) {
    return ElevatedButton(
        style: PageStyle.getButtonStyle(),
        onPressed: rtcLogic.isLogined.value ? onPressed : null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 4.h),
          child: text.toText..style = PageStyle.ts_12cffffff,
        ));
  }

  Widget title(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: text.toText..style = PageStyle.ts_12c666666,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "测试"),
      body: Column(
        children: [
          Container(
            height: 150.h,
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.w),
            decoration: const BoxDecoration(color: PageStyle.cf2f2f2),
            child: Obx(() => ListView.builder(
                  controller: logic.controller,
                  itemBuilder: (_, index) => logic.logs.elementAt(index).toText
                    ..style = PageStyle.ts_12c333333,
                  itemCount: logic.logs.length,
                )),
          ),
          Obx(
            () => Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title('呼叫'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        button(
                          '用户列表',
                          onPressed: logic.selCallUser,
                        ),
                        10.horizontalSpace,
                        button(
                          '${logic.statusNotify.value ? '关闭' : '开启'}用户的状态推送',
                          onPressed: logic.switchUserStatusNotify,
                        ),
                        10.horizontalSpace,
                        button(
                          '${logic.dndType.value ? '关闭' : '开启'}免打扰',
                          onPressed: logic.switchUserDndType,
                        ),
                      ],
                    ),
                    title('队列（坐席）'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        button(
                          '${logic.isSerivceQueueing.value ? '停止' : '开始'}服务队列',
                          onPressed: logic.switchServiceQueue,
                        ),
                        10.horizontalSpace,
                        button(
                          '获取我服务的所有队列',
                          onPressed: logic.isSerivceQueueing.value
                              ? logic.getServiceQueues
                              : null,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        button(
                          '获取我的队列状态',
                          onPressed: logic.isSerivceQueueing.value
                              ? logic.getQueueStatus
                              : null,
                        ),
                        10.horizontalSpace,
                        button(
                          '请求分配客户',
                          onPressed: logic.isSerivceQueueing.value
                              ? logic.reqAssignUser
                              : null,
                        ),
                      ],
                    ),
                    title('队列（客户）'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        button(
                          '${logic.isQueueing.value ? '停止' : '开始'}排队',
                          onPressed: logic.switchQueue,
                        ),
                        10.horizontalSpace,
                        button(
                          '获取我的排队信息',
                          onPressed: logic.getQueuingInfo,
                        ),
                      ],
                    ),
                    title('透明通道'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        button(
                          '发送点对点消息',
                          onPressed: logic.sendCmd,
                        ),
                        10.horizontalSpace,
                        button(
                          '发送点对点大数据',
                          onPressed: logic.sendBuffer,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
