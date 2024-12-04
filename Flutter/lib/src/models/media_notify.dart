import 'package:rtcsdk/rtcsdk.dart';

class MediaNotify {
  String userID;
  MEDIA_STOP_REASON? reason;
  bool? pause;

  MediaNotify({required this.userID, this.pause, this.reason});

  MediaNotify.fromJson(Map data)
      : userID = data['userID'],
        pause = data['pause'],
        reason = data['reason'] != null
            ? MEDIA_STOP_REASON.values[data['reason']]
            : null;
}
