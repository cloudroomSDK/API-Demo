import 'package:get/get.dart';
import 'package:rtcsdk/rtcsdk.dart';

class QueueListLogic extends GetxController {
  RxList<QueueInfo> queues = <QueueInfo>[].obs;

  @override
  void onInit() {
    getAllQueueInfo();
    super.onInit();
  }

  getAllQueueInfo() async {
    queues.value = await RtcSDK.queueManager.getAllQueueInfo();
  }
}
