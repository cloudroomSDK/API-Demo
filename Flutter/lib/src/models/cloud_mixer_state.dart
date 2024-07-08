import 'package:rtcsdk/rtcsdk.dart';

// 云端混图器状态变化通知
class CloudMixerState {
  String mixerID;
  String operatorID;
  MIXER_STATE state;
  String? exParam;
  CloudMixerState({
    required this.mixerID,
    required this.operatorID,
    required this.state,
    this.exParam,
  });

  CloudMixerState.fromJson(Map data)
      : mixerID = data['mixerID'],
        operatorID = data['operatorID'],
        state = MIXER_STATE.values[data["state"]],
        exParam = data['exParam'];
}
