import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:rtcsdk/rtcsdk.dart';
import 'package:rtcsdk_demo/src/resources/styles.dart';
import 'package:rtcsdk_demo/src/widgets/custom_appbar.dart';

import 'queue_list_logic.dart';

class QueueListView extends GetView<QueueListLogic> {
  QueueListView({Key? key}) : super(key: key);

  final logic = Get.find<QueueListLogic>();

  Widget _buildUserStatusItemView(QueueInfo info) => Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(
          color: PageStyle.borderColor,
        )),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              info.name,
              textAlign: TextAlign.start,
              style: PageStyle.ts_14c333333,
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.back(result: info);
            },
            child: Text(
              "确认",
              textAlign: TextAlign.end,
              style: PageStyle.ts_14c3981fc,
            ),
          )
        ],
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "选择队列"),
      body: Obx(
        () => ListView.builder(
          itemCount: logic.queues.length,
          itemBuilder: (_, index) =>
              _buildUserStatusItemView(logic.queues[index]),
        ),
      ),
    );
  }
}
