import 'package:rtcsdk/rtcsdk.dart';

// 摄像头状态变化
class VideoStatusChanged {
  String userId; // 用户id
  VSTATUS oldStatus;
  VSTATUS newStatus;

  VideoStatusChanged(
      {required this.userId, required this.oldStatus, required this.newStatus});
}
