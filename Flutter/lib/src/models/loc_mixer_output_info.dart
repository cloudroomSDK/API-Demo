import 'package:rtcsdk/rtcsdk.dart';

// 云端混图器状态变化通知
class LocMixerOutputInfo {
  String mixerID;
  String nameOrUrl;
  MixerOutputInfo mixerOutputInfo;

  LocMixerOutputInfo({
    required this.mixerID,
    required this.nameOrUrl,
    required this.mixerOutputInfo,
  });
}
