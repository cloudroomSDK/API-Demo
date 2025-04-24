import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rtcsdk/rtcsdk.dart';
import 'package:rtcsdk_demo/src/controller/app_controller.dart';
import 'package:rtcsdk_demo/src/controller/rtc_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rtcsdk_demo/src/resources/styles.dart';
import 'package:rtcsdk_demo/src/widgets/custom_appbar.dart';
import 'package:rtcsdk_demo/src/widgets/custom_button.dart';

import 'record_list_logic.dart';

class RecordList extends StatelessWidget {
  RecordList({Key? key}) : super(key: key);
  final appLogic = Get.find<AppController>();
  final rtcLogic = Get.find<RTCController>();
  final logic = Get.find<RecordListLogic>();

  Widget _buildLocRecordView(RecordFileShow file) => Ink(
        height: 80.h,
        child: InkWell(
          onTap: () {
            logic.selFile(file);
          },
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.h),
              decoration: const BoxDecoration(
                border: PageStyle.underline,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.fileName,
                    style: PageStyle.ts_14c333333,
                  ),
                  CustomButton(
                    onPressed: file.state == RECORD_FILE_STATE.RFS_NoUpload ||
                            file.state == RECORD_FILE_STATE.RFS_UploadFail
                        ? () {
                            logic.uploadRecordFile(file);
                          }
                        : null,
                    child: Text(
                      logic.getStateCn(file),
                      style: PageStyle.ts_14cffffff,
                    ),
                  )
                ],
              )),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "房间号：${logic.confId}"),
      body: Obx(() => logic.files.isEmpty
          ? Center(
              child: Text(
                "没有本地录制文件",
                style: PageStyle.ts_14c333333,
              ),
            )
          : ListView.builder(
              itemBuilder: (_, index) =>
                  _buildLocRecordView(logic.files.elementAt(index)),
              itemCount: logic.files.length,
            )),
    );
  }
}
