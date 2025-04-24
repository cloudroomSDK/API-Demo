import 'dart:async';

import 'package:rtcsdk_demo/src/controller/rtc_controller.dart';
import 'package:rtcsdk/rtcsdk.dart';
import 'package:get/get.dart';
import 'package:rtcsdk_demo/src/models/record_file_state.dart';
// import 'package:rtcsdk_demo/src/utils/logger_util.dart';

class RecordListLogic extends GetxController {
  final rtcLogic = Get.find<RTCController>();
  final String confId = Get.arguments['confId'];
  RxList<RecordFileShow> files = <RecordFileShow>[].obs; // 本地录制文件列表
  List<StreamSubscription> subs = [];

  @override
  onInit() {
    // getAllRecordFiles();
    subs.addAll([
      rtcLogic.onNotifyRecordFileStateChanged
          .listen((RecordFileState fileState) {
        RecordFileShow? rfile = files
            .firstWhereOrNull((file) => file.fileName == fileState.fileName);
        if (rfile != null) {
          rfile.state = fileState.state;
          files.refresh();
        }
      }),
    ]);
    super.onInit();
  }

  @override
  onClose() {
    for (StreamSubscription sub in subs) {
      sub.cancel();
    }
    super.onClose();
  }

  // void getAllRecordFiles() async {
  //   List<RecordFileShow> recordFiles =
  //       await RtcSDK.recordManager.getAllRecordFiles();
  //   files.value = recordFiles;
  // }

  // uploadRecordFile(RecordFileShow file) async {
  //   UploadRecordFileResult result =
  //       await RtcSDK.recordManager.uploadRecordFile(file.fileName);
  //   Logger.log('UploadRecordFileResult :${result.toJson()}');
  // }

  void selFile(RecordFileShow file) {
    Get.back(result: file);
  }

  String getStateCn(RecordFileShow file) {
    if (file.state == RECORD_FILE_STATE.RFS_NoUpload) {
      return "未上传";
    } else if (file.state == RECORD_FILE_STATE.RFS_Uploading) {
      return "上传中";
    } else if (file.state == RECORD_FILE_STATE.RFS_Uploaded) {
      return "已上传";
    }
    return "上传失败";
  }
}
