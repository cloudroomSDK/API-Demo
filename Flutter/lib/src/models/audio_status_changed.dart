import 'package:rtcsdk/rtcsdk.dart';

// 麦克风状态变化
class AudioStatusChanged {
  String userId; // 用户id
  ASTATUS oldStatus;
  ASTATUS newStatus;

  AudioStatusChanged(
      {required this.userId, required this.oldStatus, required this.newStatus});
}
