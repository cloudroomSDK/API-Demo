import 'dart:convert';
import 'package:cloudroomvideosdk/cr_defines.dart';
import 'package:cloudroomvideosdk/cr_observer.dart';

class CrNotify {
  CrNotify._internal();
  static final CrNotify instance = CrNotify._internal();
  factory CrNotify() => instance;

  static final subScribe = SubScribeSingleton.instance;

  notify(method, arguments) {
    switch (method) {
      // 通知用户掉线
      case "lineOff":
        final int sdkErr = arguments["sdkErr"];
        subScribe.emit("lineOff", sdkErr);
        break;
      // 某用户进入了房间
      case "userEnterMeeting":
        final String userID = arguments["userID"];
        subScribe.emit("userEnterMeeting", userID);
        break;
      // 某用户离开了房间
      case "userLeftMeeting":
        final String userID = arguments["userID"];
        subScribe.emit("userLeftMeeting", userID);
        break;
      // 通知从房间里掉线了
      case "meetingDropped":
        final int reason = arguments["reason"];
        subScribe.emit(
            "meetingDropped", CR_MEETING_DROPPED_REASON.values[reason]);
        break;
      // 房间已被结束
      // case "meetingStoped":
      //   subScribe.emit("meetingStoped");
      //   break;
      // 网络变化通知
      case "netStateChanged":
        final int level = arguments["level"];
        subScribe.emit("netStateChanged", level);
        break;
      // 通知摄像头状态变化
      case "videoStatusChanged":
        final String userId = arguments["userID"];
        final int newStatusIdx = arguments["newStatus"];
        final int oldStatusIdx = arguments["oldStatus"];
        CrVideoStatusChanged vsc = CrVideoStatusChanged(
          userId: userId,
          newStatus: CR_VSTATUS.values[newStatusIdx],
          oldStatus: CR_VSTATUS.values[oldStatusIdx],
        );
        subScribe.emit("videoStatusChanged", vsc);
        break;
      // 通知用户的视频设备有变化
      case "videoDevChanged":
        final String userID = arguments["userID"];
        subScribe.emit("videoDevChanged", userID);
        break;
      // 通知音频状态变化
      case "audioStatusChanged":
        final String userId = arguments["userID"];
        final int newStatusIdx = arguments["newStatus"];
        final int oldStatusIdx = arguments["oldStatus"];
        CrAudioStatusChanged asc = CrAudioStatusChanged(
          userId: userId,
          newStatus: CR_ASTATUS.values[newStatusIdx],
          oldStatus: CR_ASTATUS.values[oldStatusIdx],
        );
        subScribe.emit("audioStatusChanged", asc);
        break;
      // 通知本地音频设备有变化
      case "audioDevChanged":
        subScribe.emit("audioDevChanged");
        break;
      case "micEnergyUpdate":
        final String userId = arguments["userID"];
        final int newLevel = arguments["newLevel"];
        final int oldLevel = arguments["oldLevel"];
        CrMicEnergy micEnergy =
            CrMicEnergy(userId: userId, newLevel: newLevel, oldLevel: oldLevel);
        subScribe.emit("micEnergyUpdate", micEnergy);
        break;
      // 通知开启屏幕共享
      case "notifyScreenShareStarted":
        subScribe.emit("notifyScreenShareStarted");
        break;
      // 通知停止屏幕共享
      case "notifyScreenShareStopped":
        subScribe.emit("notifyScreenShareStopped");
        break;
      // 通知开启屏幕共享标注
      case "notifyScreenMarkStarted":
        subScribe.emit("notifyScreenMarkStarted");
        break;
      // 通知停止屏幕共享标注
      case "notifyScreenMarkStopped":
        subScribe.emit("notifyScreenMarkStopped");
        break;
      // 本地录制文件、本地直播信息通知
      case "locMixerOutputInfo":
        Map outputInfo = json.decode(arguments["outputInfo"]);
        CrMixerOutputInfo locMixerOutputInfo = CrMixerOutputInfo();
        locMixerOutputInfo.duration = outputInfo["duration"];
        locMixerOutputInfo.fileSize = outputInfo["fileSize"];
        locMixerOutputInfo.errCode = outputInfo["errCode"];
        locMixerOutputInfo.state =
            CR_MIXER_OUTPUT_STATE.values[outputInfo["state"]];
        subScribe.emit("locMixerOutputInfo", locMixerOutputInfo);
        break;
      case "locMixerStateChanged":
        String mixerID = arguments["mixerID"];
        CR_MIXER_OUTPUT_STATE state =
            CR_MIXER_OUTPUT_STATE.values[arguments["state"]];
        CrLocMixerState crLocMixerState =
            CrLocMixerState(mixerID: mixerID, state: state);
        subScribe.emit("locMixerStateChanged", crLocMixerState);
        break;
      // 云端录制、云端直播状态变化通知
      case "svrMixerStateChanged":
        String operatorID = arguments["operatorID"];
        CR_MIXER_OUTPUT_STATE state =
            CR_MIXER_OUTPUT_STATE.values[arguments["state"]];
        int sdkErr = arguments["err"];
        CrSvrMixerState crSvrMixerState = CrSvrMixerState(
            operatorID: operatorID, state: state, sdkErr: sdkErr);
        subScribe.emit("svrMixerStateChanged", crSvrMixerState);
        break;
      // 云端录制、云端直播内容变化通知
      case "svrMixerCfgChanged":
        subScribe.emit("svrMixerCfgChanged");
        break;
      // 云端录制文件、云端直播信息变化通知
      case "svrMixerOutputInfo":
        Map outputInfo = json.decode(arguments["outputInfo"]);
        CrMixerOutputInfo svrMixerOutputInfo = CrMixerOutputInfo();
        svrMixerOutputInfo.duration = outputInfo["duration"];
        svrMixerOutputInfo.fileSize = outputInfo["fileSize"];
        svrMixerOutputInfo.errCode = outputInfo["errCode"];
        svrMixerOutputInfo.state =
            CR_MIXER_OUTPUT_STATE.values[outputInfo["state"]];
        subScribe.emit("svrMixerOutputInfo", svrMixerOutputInfo);
        break;
      // 通知影音文件打开
      case "notifyMediaOpened":
        int totalTime = arguments["totalTime"];
        int width = arguments["width"];
        int height = arguments["height"];
        subScribe.emit(
            "notifyMediaOpened",
            CrMediaFileInfo(
                totalTime: totalTime, width: width, height: height));
        break;
      // 通知影音开始播放
      case "notifyMediaStart":
        String userID = arguments["userID"];
        subScribe.emit("notifyMediaStart", CrMediaNotify(userID: userID));
        break;
      // 通知影音是否暂停播放
      case "notifyMediaPause":
        String userID = arguments["userID"];
        bool pause = arguments["pause"];
        subScribe.emit(
            "notifyMediaPause", CrMediaNotify(userID: userID, pause: pause));
        break;
      // 通知影音播放停止
      case "notifyMediaStop":
        String userID = arguments["userID"];
        int reason = arguments["reason"];
        subScribe.emit(
            "notifyMediaStop",
            CrMediaNotify(
                userID: userID, reason: CR_MEDIA_STOP_REASON.values[reason]));
        break;
      // 聊天信息通知
      case "notifyMeetingCustomMsg":
        String fromUserID = arguments["fromUserID"];
        String text = arguments["text"];
        subScribe.emit("notifyMeetingCustomMsg", CrChatMsg(fromUserID, text));
        break;
    }
  }
}
