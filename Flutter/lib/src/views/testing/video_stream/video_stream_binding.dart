import 'package:get/get.dart';

import 'video_stream_logic.dart';

class VideoStreamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoStreamLogic>(
      () => VideoStreamLogic(),
    );
  }
}
