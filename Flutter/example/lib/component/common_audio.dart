import 'dart:async';

import 'package:cloudroomvideosdk/cloudroomvideosdk.dart';
import 'package:cloudroomvideosdk_example/application/application.dart';
import 'package:cloudroomvideosdk_example/application/utils.dart';

class CommonAudio {
  late Function _setState;

  bool _isOpenMic = false; // 是否开启麦克风
  bool _isSpeakerOut = false; // 是否外放（扬声器）

  bool get isOpenMic => _isOpenMic;
  bool get isSpeakerOut => _isSpeakerOut;

  int _speakerVolume = 0;
  int get speakerVolume => _speakerVolume;

  addSDKAudioObserver(ob) {
    _setState = ob.setState;
    CrSDK.on("audioStatusChanged", audioStatusChanged);
  }

  removeSDKAudioObserver() {
    _setState = () {};
    CrSDK.off("audioStatusChanged", audioStatusChanged);
  }

  audioStatusChanged(CrAudioStatusChanged asc) {
    String userId = GlobalConfig.instance.userID;
    if (asc.userId == userId) {
      _setState(() => _isOpenMic = asc.newStatus == CR_ASTATUS.AOPEN);
    }
  }

  // 麦克风开关
  Future switchMicPhone(String userId, bool isOpenMic) {
    _setState(() => _isOpenMic = isOpenMic);
    return isOpenMic
        ? CrSDK.instance.openMic(userId)
        : CrSDK.instance.closeMic(userId);
  }

  // 获取外放状态
  Future getSpeakerOut() {
    return CrSDK.instance
        .getSpeakerOut()
        .then((bool isSpeakerOut) => _isSpeakerOut = isSpeakerOut);
  }

  // 设置外放状态
  void setSpeakerOut(bool isSpeakerOut) {
    _setState(() => _isSpeakerOut = isSpeakerOut);
    Utils.debounce("setSpeakerOut", () {
      CrSDK.instance.setSpeakerOut(isSpeakerOut).catchError((value) {
        _setState(() => _isSpeakerOut = !isSpeakerOut);
      });
    });
  }

  Future getSpeakerVolume() {
    return CrSDK.instance
        .getSpeakerVolume()
        .then((int vol) => _speakerVolume = vol);
  }

  Future setSpeakerVolume(int vol) {
    int speakerVolume = _speakerVolume;
    _setState(() => _speakerVolume = vol);
    return CrSDK.instance.setSpeakerVolume(vol).catchError((value) {
      _setState(() => _speakerVolume = speakerVolume);
    });
  }
}
