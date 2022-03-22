package com.example.cloudroomvideosdk;

import android.content.Context;
import android.content.Intent;
import android.graphics.Rect;
import android.os.Environment;
import com.cloudroom.cloudroomvideosdk.CRMeetingCallback;
import com.cloudroom.cloudroomvideosdk.CRMgrCallback;
import com.cloudroom.cloudroomvideosdk.CloudroomVideoMeeting;
import com.cloudroom.cloudroomvideosdk.CloudroomVideoMgr;
import com.cloudroom.cloudroomvideosdk.CloudroomVideoSDK;
import com.cloudroom.cloudroomvideosdk.VideoUIView;
import com.cloudroom.cloudroomvideosdk.model.ASTATUS;
import com.cloudroom.cloudroomvideosdk.model.AudioCfg;
import com.cloudroom.cloudroomvideosdk.model.CRVIDEOSDK_ERR_DEF;
import com.cloudroom.cloudroomvideosdk.model.CRVIDEOSDK_MEETING_DROPPED_REASON;
import com.cloudroom.cloudroomvideosdk.model.LoginDat;
import com.cloudroom.cloudroomvideosdk.model.MEDIA_STATE;
import com.cloudroom.cloudroomvideosdk.model.MEDIA_STOP_REASON;
import com.cloudroom.cloudroomvideosdk.model.MIXER_OUTPUT_TYPE;
import com.cloudroom.cloudroomvideosdk.model.MIXER_STATE;
import com.cloudroom.cloudroomvideosdk.model.MIXER_VCONTENT_TYPE;
import com.cloudroom.cloudroomvideosdk.model.MediaInfo;
import com.cloudroom.cloudroomvideosdk.model.MeetInfo;
import com.cloudroom.cloudroomvideosdk.model.MemberInfo;
import com.cloudroom.cloudroomvideosdk.model.MixerCfg;
import com.cloudroom.cloudroomvideosdk.model.MixerCotent;
import com.cloudroom.cloudroomvideosdk.model.MixerOutPutCfg;
import com.cloudroom.cloudroomvideosdk.model.MixerOutputInfo;
import com.cloudroom.cloudroomvideosdk.model.SDK_LOG_LEVEL_DEF;
import com.cloudroom.cloudroomvideosdk.model.ScreenShareCfg;
import com.cloudroom.cloudroomvideosdk.model.SdkInitDat;
import com.cloudroom.cloudroomvideosdk.model.Size;
import com.cloudroom.cloudroomvideosdk.model.UsrVideoId;
import com.cloudroom.cloudroomvideosdk.model.UsrVideoInfo;
import com.cloudroom.cloudroomvideosdk.model.VSTATUS;
import com.cloudroom.cloudroomvideosdk.model.VideoCfg;
import com.example.cloudroomvideosdk.CloudroomMediaView;
import com.example.cloudroomvideosdk.CloudroomPlatformView;
import com.example.cloudroomvideosdk.CloudroomPlatformViewFactory;
import com.example.cloudroomvideosdk.CloudroomScreenShareView;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import io.flutter.Log;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CloudroomSDKMethod {

  private static String TAG = "FlutterSDK";
  private static EventChannel.EventSink eventSink;
  private static Gson gson = new Gson();

  private static final String External_Storage_Dir = Environment
    .getExternalStorageDirectory()
    .getAbsolutePath();

  public static void getExternalStorageDir(MethodCall call, Result result) {
    result.success(External_Storage_Dir);
  }

  public static void CRLogdebug(String log) {
    CloudroomVideoSDK
      .getInstance()
      .writeLog(SDK_LOG_LEVEL_DEF.SDKLEVEL_DEBUG, TAG + ":" + log);
  }

  public static void GetCloudroomVideoSDKVer(MethodCall call, Result result) {
    String sdkVer = CloudroomVideoSDK.getInstance().GetCloudroomVideoSDKVer();
    result.success(sdkVer);
  }

  public static void init(
    MethodCall call,
    Result result,
    Context context,
    EventChannel.EventSink evtSink
  ) {
    eventSink = evtSink;
    String sdkInitDatjson = call.argument("sdkInitDat");
    SdkInitDat initDat = gson.fromJson(sdkInitDatjson, SdkInitDat.class);
    // 初始化SDK
    CRVIDEOSDK_ERR_DEF ret = CloudroomVideoSDK
      .getInstance()
      .init(context, initDat);
    if (ret == CRVIDEOSDK_ERR_DEF.CRVIDEOSDK_NOERR) {
      CloudroomVideoMgr.getInstance().registerCallback(mMgrCallback);
      CloudroomVideoMeeting.getInstance().registerCallback(mMeetingCallback);
    }
    result.success(ret.value());
  }

  public static void uninit(MethodCall call, Result result) {
    CloudroomVideoMgr.getInstance().unregisterCallback(mMgrCallback);
    CloudroomVideoMeeting.getInstance().unregisterCallback(mMeetingCallback);
    CloudroomVideoSDK.getInstance().uninit();
    result.success("");
  }

  public static void getServerAddr(MethodCall call, Result result) {
    String serverAddr = CloudroomVideoSDK.getInstance().serverAddr();
    result.success(serverAddr);
  }

  public static void setServerAddr(MethodCall call, Result result) {
    String serverAddr = call.argument("serverAddr");
    CloudroomVideoSDK.getInstance().setServerAddr(serverAddr);
    result.success("");
  }

  public static void login(MethodCall call, Result result) {
    String loginDatjson = call.argument("loginDat");
    String cookie = (String) call.argument("cookie");
    LoginDat dat = gson.fromJson(loginDatjson, LoginDat.class);
    CloudroomVideoMgr.getInstance().login(dat, cookie);
    result.success("");
  }

  public static void logout(MethodCall call, Result result) {
    CloudroomVideoMgr.getInstance().logout();
    result.success("");
  }

  public static void getMyUserID(MethodCall call, Result result) {
    String userID = CloudroomVideoMeeting.getInstance().getMyUserID();
    result.success(userID);
  }

  // 获取房间所有成员的列表
  public static void getAllMembers(MethodCall call, Result result) {
    ArrayList<MemberInfo> memberInfos = CloudroomVideoMeeting
      .getInstance()
      .getAllMembers();
    String memberInfosJson = gson.toJson(memberInfos);
    result.success(memberInfosJson);
  }

  // 获取某个用户的信息
  public static void getMemberInfo(MethodCall call, Result result) {
    String userID = call.argument("userID");
    MemberInfo memberInfo = CloudroomVideoMeeting
      .getInstance()
      .getMemberInfo(userID);
    result.success(gson.toJson(memberInfo));
  }

  // 获取某个用户的昵称
  public static void getNickName(MethodCall call, Result result) {
    String userID = call.argument("userID");
    String nickname = CloudroomVideoMeeting.getInstance().getNickName(userID);
    result.success(nickname);
  }

  // 设置某个用户的昵称
  public static void setNickName(MethodCall call, Result result) {
    String userID = call.argument("userID");
    String nickname = call.argument("nickName");
    CloudroomVideoMeeting.getInstance().setNickName(userID, nickname);
    result.success("");
  }

  //判断某个用户是否在房间中
  public static void isUserInMeeting(MethodCall call, Result result) {
    String userID = call.argument("userID");
    boolean isUserInMeeting = CloudroomVideoMeeting
      .getInstance()
      .isUserInMeeting(userID);
    result.success(isUserInMeeting);
  }

  // 创建房间
  public static void createMeeting(MethodCall call, Result result) {
    String cookie = (String) call.argument("cookie");
    CloudroomVideoMgr
      .getInstance()
      .createMeeting(cookie);
    result.success("");
  }

  // 进入房间
  public static void enterMeeting(MethodCall call, Result result) {
    int meetID = (int) call.argument("meetID");
    // String pswd = call.argument("pswd");
    // String userID = call.argument("userID");
    // String nickName = call.argument("nickName");
    String cookie = call.argument("cookie");
    CloudroomVideoMeeting.getInstance().enterMeeting(meetID);
    result.success("");
  }

  // 销毁房间
  public static void destroyMeeting(MethodCall call, Result result) {
    int meetID = (int) call.argument("meetID");
    String cookie = call.argument("cookie");
    CloudroomVideoMgr.getInstance().destroyMeeting(meetID, cookie);
    result.success("");
  }

  // 退出房间
  public static void exitMeeting(MethodCall call, Result result) {
    CloudroomVideoMeeting.getInstance().exitMeeting();
    result.success("");
  }

  /**
   * 麦克风
   */

  // 打开麦克风
  public static void openMic(MethodCall call, Result result) {
    String userID = call.argument("userID");
    CloudroomVideoMeeting.getInstance().openMic(userID);
    result.success("");
  }

  // 关闭麦克风
  public static void closeMic(MethodCall call, Result result) {
    String userID = call.argument("userID");
    CloudroomVideoMeeting.getInstance().closeMic(userID);
    result.success("");
  }

  // 获取麦克风参数配置
  public static void getAudioCfg(MethodCall call, Result result) {
    String userID = call.argument("userID");
    AudioCfg audioCfg = CloudroomVideoMeeting.getInstance().getAudioCfg();
    result.success(gson.toJson(audioCfg));
  }

  // 设置麦克风参数配置
  public static void setAudioCfg(MethodCall call, Result result) {
    String audioCfgJson = call.argument("audioCfg");
    AudioCfg acfg = gson.fromJson(audioCfgJson, AudioCfg.class);
    CloudroomVideoMeeting.getInstance().setAudioCfg(acfg);
    result.success("");
  }

  // 获取用户的麦状态
  public static void getAudioStatus(MethodCall call, Result result) {
    String userID = call.argument("userID");
    ASTATUS AStatus = CloudroomVideoMeeting
      .getInstance()
      .getAudioStatus(userID);
    result.success(AStatus.value());
  }

  // 获取麦克风音量大小
  public static void getMicVolume(MethodCall call, Result result) {
    int volume = CloudroomVideoMeeting.getInstance().getMicVolume();
    result.success(volume);
  }

  // 获取外放状态
  public static void getSpeakerOut(MethodCall call, Result result) {
    boolean isSpeakerOut = CloudroomVideoMeeting.getInstance().getSpeakerOut();
    result.success(isSpeakerOut);
  }

  // 设置外放状态
  public static void setSpeakerOut(MethodCall call, Result result) {
    boolean speakerOut = (boolean) call.argument("speakerOut");
    boolean isSpeakerOut = CloudroomVideoMeeting
      .getInstance()
      .setSpeakerOut(speakerOut);
    result.success(isSpeakerOut);
  }

  // 获取本地扬声器音量
  public static void getSpeakerVolume(MethodCall call, Result result) {
    int speakerVolume = CloudroomVideoMeeting.getInstance().getSpeakerVolume();
    result.success(speakerVolume);
  }

  // 设置本地扬声器音量
  public static void setSpeakerVolume(MethodCall call, Result result) {
    int speakerVolume = (int) call.argument("speakerVolume");
    boolean isSetSpeakerVolumeSuccess = CloudroomVideoMeeting
      .getInstance()
      .setSpeakerVolume(speakerVolume);
    result.success(isSetSpeakerVolumeSuccess);
  }

  // 获取播放是否静音
  public static void getSpeakerMute(MethodCall call, Result result) {
    boolean isSpeakerMute = CloudroomVideoMeeting
      .getInstance()
      .getSpeakerMute();
    result.success(isSpeakerMute);
  }

  // 获取播放是否静音
  public static void setSpeakerMute(MethodCall call, Result result) {
    boolean mute = (boolean) call.argument("mute");
    CloudroomVideoMeeting.getInstance().setSpeakerMute(mute);
    result.success(mute);
  }

  /**
   * 视频
   */
  // 创建视频容器，添加视频
  public static void setUsrVideoId(MethodCall call, Result result) {
    int viewID = (int) call.argument("viewID");
    String usrVideoIdStr = call.argument("usrVideoId");
    UsrVideoId usrVideoId = gson.fromJson(usrVideoIdStr, UsrVideoId.class);
    CloudroomPlatformView platformView = CloudroomPlatformViewFactory
      .getInstance()
      .getPlatformView(viewID);
    if (platformView != null) {
      VideoUIView view = platformView.getVideoUIView();
      view.setUsrVideoId(usrVideoId);
    }
    result.success("");
  }

  // 销毁视频容器
  public static void destroyPlatformView(MethodCall call, Result result) {
    int viewID = (int) call.argument("viewID");
    Boolean isDestroy = CloudroomPlatformViewFactory
      .getInstance()
      .destroyPlatformView(viewID);
    result.success(isDestroy);
  }

  // 获取视频比例
  public static void getScaleType(MethodCall call, Result result) {
    int viewID = (int) call.argument("viewID");
    CloudroomPlatformView platformView = CloudroomPlatformViewFactory
      .getInstance()
      .getPlatformView(viewID);
    if (platformView != null) {
      VideoUIView view = platformView.getVideoUIView();
      int scaleType = view.getScaleType();
      result.success(scaleType);
    } else {
      result.success(-1);
    }
  }

  // 设置视频比例
  public static void setScaleType(MethodCall call, Result result) {
    int viewID = (int) call.argument("viewID");
    int scaleType = (int) call.argument("scaleType");
    CloudroomPlatformView platformView = CloudroomPlatformViewFactory
      .getInstance()
      .getPlatformView(viewID);
    if (platformView != null) {
      VideoUIView view = platformView.getVideoUIView();
      view.setScaleType(scaleType);
    }
    result.success("");
  }

  // 打开摄像头
  public static void openVideo(MethodCall call, Result result) {
    String userID = call.argument("userID");
    CloudroomVideoMeeting.getInstance().openVideo(userID);
    result.success("");
  }

  // 关闭摄像头
  public static void closeVideo(MethodCall call, Result result) {
    String userID = call.argument("userID");
    CloudroomVideoMeeting.getInstance().closeVideo(userID);
    result.success("");
  }

  // 获取设置的摄像头参数
  public static void getVideoCfg(MethodCall call, Result result) {
    VideoCfg videoCfg = CloudroomVideoMeeting.getInstance().getVideoCfg();
    result.success(gson.toJson(videoCfg));
  }

  // 设置摄像头参数
  public static void setVideoCfg(MethodCall call, Result result) {
    String videoCfgJson = call.argument("videoCfg");
    VideoCfg vcfg = gson.fromJson(videoCfgJson, VideoCfg.class);
    CloudroomVideoMeeting.getInstance().setVideoCfg(vcfg);
    result.success("");
  }

  // 查看观看摄像头的列表
  public static void getWatchableVideos(MethodCall call, Result result) {
    ArrayList<UsrVideoId> watchableVideos = CloudroomVideoMeeting
      .getInstance()
      .getWatchableVideos();
    result.success(gson.toJson(watchableVideos));
  }

  // 获取用户所有的摄像头信息
  public static void getAllVideoInfo(MethodCall call, Result result) {
    String userID = call.argument("userID");
    ArrayList<UsrVideoInfo> videosInfo = CloudroomVideoMeeting
      .getInstance()
      .getAllVideoInfo(userID);
    result.success(gson.toJson(videosInfo));
  }

  // 获取指定用户的默认摄像头 ，如果用户没有摄像头，返回0
  public static void getDefaultVideo(MethodCall call, Result result) {
    String userID = call.argument("userID");
    short defaultVideo = CloudroomVideoMeeting
      .getInstance()
      .getDefaultVideo(userID);
    result.success(defaultVideo);
  }

  // 设置默认的摄像头
  public static void setDefaultVideo(MethodCall call, Result result) {
    String userID = call.argument("userID");
    Integer videoID = call.argument("videoID");
    short vid = videoID.shortValue();
    CloudroomVideoMeeting.getInstance().setDefaultVideo(userID, vid);
    result.success("");
  }

  /**
   * 屏幕共享
   */
  // 获取屏幕共享是否已开启
  public static void isScreenShareStarted(MethodCall call, Result result) {
    Boolean isScreenShareStarted = CloudroomVideoMeeting
      .getInstance()
      .isScreenShareStarted();
    result.success(isScreenShareStarted);
  }

  // 获取屏幕共享配置
  public static void getScreenShareCfg(MethodCall call, Result result) {
    ScreenShareCfg screenShareCfg = CloudroomVideoMeeting
      .getInstance()
      .getScreenShareCfg();
    String screenShareCfgJson = gson.toJson(screenShareCfg);
    result.success(screenShareCfgJson);
  }

  // 设置屏幕共享配置
  public static void setScreenShareCfg(MethodCall call, Result result) {
    String ssCfgStr = call.argument("screenShareCfg");
    ScreenShareCfg ssCfg = gson.fromJson(ssCfgStr, ScreenShareCfg.class);
    CloudroomVideoMeeting.getInstance().setScreenShareCfg(ssCfg);
    result.success("");
  }

  // 开始屏幕共享
  public static void startScreenShare(MethodCall call, Result result) {
    CloudroomVideoMeeting.getInstance().startScreenShare();
    result.success("");
  }

  // 停止屏幕共享
  public static void stopScreenShare(MethodCall call, Result result) {
    CloudroomVideoMeeting.getInstance().stopScreenShare();
    result.success("");
  }

  // 开启标注
  public static void startScreenMark(MethodCall call, Result result) {
    CloudroomVideoMeeting.getInstance().startScreenMark();
    result.success("");
  }

  // 停止标注
  public static void stopScreenMark(MethodCall call, Result result) {
    CloudroomVideoMeeting.getInstance().stopScreenMark();
    result.success("");
  }

  // 删除共享屏幕容器
  public static void destroyScreenShareView(MethodCall call, Result result) {
    int viewID = (int) call.argument("viewID");
    Boolean isDestroy = CloudroomPlatformViewFactory
      .getInstance()
      .destroyScreenShareView(viewID);
    result.success(isDestroy);
  }

  /**
   * 录制
   */
  private static ArrayList<MixerCotent> addContents(
    ArrayList<Map> mixerCotentRects
  ) {
    // 图像内容集合
    ArrayList<MixerCotent> contents = new ArrayList<MixerCotent>();
    for (Map mcr : mixerCotentRects) {
      String mUserId = (String) mcr.get("userId");
      int mtype = ((Double) mcr.get("type")).intValue();
      int mwidth = ((Double) mcr.get("width")).intValue();
      int mheight = ((Double) mcr.get("height")).intValue();
      int mleft = ((Double) mcr.get("left")).intValue();
      int mtop = ((Double) mcr.get("top")).intValue();
      int mright = mleft + mwidth;
      int mbottom = mtop + mheight;
      Rect rect = new Rect(mleft, mtop, mright, mbottom);
      if (mtype == 0) {
        short mcamId = ((Double) mcr.get("camId")).shortValue();
        MixerCotent mCotent = MixerCotent.createVideoContent(
          mUserId,
          mcamId,
          rect
        );
        contents.add(mCotent);
      } else if (mtype == 1) {
        String mresId = (String) mcr.get("resId");
        MixerCotent mCotent = MixerCotent.createPicContent(mresId, rect);
        contents.add(mCotent); // 添加到内容列表
      } else if (mtype == 2) {
        MixerCotent mCotent = MixerCotent.createScreenContent(rect);
        contents.add(mCotent);
      } else if (mtype == 3) {
        MixerCotent mCotent = MixerCotent.createMediaContent(rect);
        contents.add(mCotent);
      } else if (mtype == 4) {
        MixerCotent mCotent = new MixerCotent(
          MIXER_VCONTENT_TYPE.MIXVTP_TIMESTAMP,
          rect
        );
        contents.add(mCotent);
      } else if (mtype == 5) {
        MixerCotent mCotent = MixerCotent.createRemoteScreenContent(rect);
        contents.add(mCotent);
      } else if (mtype == 7) {
        String mtext = (String) mcr.get("text");
        MixerCotent mCotent = MixerCotent.createTextContent(mtext, rect);
        contents.add(mCotent);
      }
    }

    return contents;
  }

  // 创建混图器
  public static void createLocMixer(MethodCall call, Result result) {
    String mixerCfgJson = call.argument("mixerCfg");
    String mixerCotentRectJson = call.argument("mixerCotentRects");
    String mixerID = call.argument("mixerID");

    // 混图器参数配置
    MixerCfg mixerCfg = gson.fromJson(mixerCfgJson, MixerCfg.class);
    // 设置混图器内容
    ArrayList<Map> mixerCotentRects = gson.fromJson(
      mixerCotentRectJson,
      new TypeToken<ArrayList<Map>>() {}.getType()
    );
    // 图像内容集合
    ArrayList<MixerCotent> contents = addContents(mixerCotentRects);
    // 创建混图器, 设置混图器编号
    CRVIDEOSDK_ERR_DEF errCode = CloudroomVideoMeeting
      .getInstance()
      .createLocMixer(mixerID, mixerCfg, contents);
    result.success(errCode.value());
  }

  // 添加输出到录像文件
  public static void addLocMixerOutput(MethodCall call, Result result) {
    String mixerID = call.argument("mixerID");
    String mixerOutPutCfgsJson = call.argument("mixerOutPutCfgs");
    // 混图器输出参数配置
    ArrayList<MixerOutPutCfg> cfgs = gson.fromJson(
      mixerOutPutCfgsJson,
      new TypeToken<ArrayList<MixerOutPutCfg>>() {}.getType()
    );
    CRVIDEOSDK_ERR_DEF errCode = CloudroomVideoMeeting
      .getInstance()
      .addLocMixerOutput(mixerID, cfgs);
    result.success(errCode.value());
  }

  // 停止本地录制、直播推流 , 所有输出停止后并不会消毁混图器，如果混图器不再需要请手工消毁
  public static void rmLocMixerOutput(MethodCall call, Result result) {
    String mixerID = call.argument("mixerID");
    String nameOrUrlsJson = call.argument("nameOrUrls");
    ArrayList<String> nameOrUrls = gson.fromJson(
      nameOrUrlsJson,
      new TypeToken<ArrayList<String>>() {}.getType()
    );
    CloudroomVideoMeeting.getInstance().rmLocMixerOutput(mixerID, nameOrUrls);
    result.success("");
  }

  // 更新混图器
  public static void updateLocMixerContent(MethodCall call, Result result) {
    String mixerCotentRectJson = call.argument("mixerCotentRects");
    String mixerID = call.argument("mixerID");

    // 设置混图器内容
    ArrayList<Map> mixerCotentRects = gson.fromJson(
      mixerCotentRectJson,
      new TypeToken<ArrayList<Map>>() {}.getType()
    );
    // 图像内容集合
    ArrayList<MixerCotent> contents = addContents(mixerCotentRects);
    // 更新图像内容
    CRVIDEOSDK_ERR_DEF errCode = CloudroomVideoMeeting
      .getInstance()
      .updateLocMixerContent(mixerID, contents);
    result.success(errCode.value());
  }

  // 消毁混图器， 输出自动结束
  public static void destroyLocMixer(MethodCall call, Result result) {
    String mixerID = call.argument("mixerID");
    CloudroomVideoMeeting.getInstance().destroyLocMixer(mixerID);
    result.success("");
  }

  // 获取本地混图器状态
  public static void getLocMixerState(MethodCall call, Result result) {
    String mixerID = call.argument("mixerID");
    MIXER_STATE mixerState = CloudroomVideoMeeting
      .getInstance()
      .getLocMixerState(mixerID);
    result.success(mixerState.value());
  }

  // 获取云端录制、云端直播状态
  public static void getSvrMixerState(MethodCall call, Result result) {
    MIXER_STATE mixerState = CloudroomVideoMeeting
      .getInstance()
      .getSvrMixerState();
    result.success(mixerState.value());
  }

  // 开启云端录制
  public static void startSvrMixer(MethodCall call, Result result) {
    // 混图器参数配置
    String mutiMixerCfg = call.argument("mutiMixerCfg");
    // 混图器内容
    String mutiMixerContents = call.argument("mutiMixerContents");
    // 混图器输出配置
    String mutiMixerOutput = call.argument("mutiMixerOutput");
    //开启云端录制
    CRVIDEOSDK_ERR_DEF errCode = CloudroomVideoMeeting
      .getInstance()
      .startSvrMixer(mutiMixerCfg, mutiMixerContents, mutiMixerOutput);
    result.success(errCode.value());
  }

  // 更新云端录制、云端直播内容
  public static void updateSvrMixerContent(MethodCall call, Result result) {
    // 混图器内容
    String mutiMixerContents = call.argument("mutiMixerContents"); //更新录制内容
    CRVIDEOSDK_ERR_DEF svruErrCode = CloudroomVideoMeeting
      .getInstance()
      .updateSvrMixerContent(mutiMixerContents);
    result.success(svruErrCode.value());
  }

  // 停止云端录制、云端直播
  public static void stopSvrMixer(MethodCall call, Result result) {
    CloudroomVideoMeeting.getInstance().stopSvrMixer();
    result.success("");
  }

  /**
   * 影音播放
   */
  // 销毁影音播放容器
  public static void destroyMediaView(MethodCall call, Result result) {
    int viewID = (int) call.argument("viewID");
    Boolean isDestroyMediaView = CloudroomPlatformViewFactory
      .getInstance()
      .destroyMediaView(viewID);
    result.success(isDestroyMediaView);
  }

  // 获取影音共享配置参数
  public static void getMediaCfg(MethodCall call, Result result) {
    VideoCfg cfg = CloudroomVideoMeeting.getInstance().getMediaCfg();
    result.success(gson.toJson(cfg));
  }

  // 配置远程影音共享时，图像质量参数
  public static void setMediaCfg(MethodCall call, Result result) {
    String mediaCfgJson = call.argument("mediaCfg");
    VideoCfg cfg = gson.fromJson(mediaCfgJson, VideoCfg.class);
    CloudroomVideoMeeting.getInstance().setMediaCfg(cfg);
    result.success("");
  }

  // 正在播放的影音信息
  public static void getMediaInfo(MethodCall call, Result result) {
    MediaInfo mediaInfo = CloudroomVideoMeeting.getInstance().getMediaInfo();
    Map data = new HashMap();
    data.put("userID", mediaInfo.userID);
    data.put("mediaName", mediaInfo.mediaName);
    data.put("state", mediaInfo.state.value());
    String mediaInfoJson = gson.toJson(data);
    result.success(mediaInfoJson);
  }

  // 读取影音播放的音量 类型范围（0-255）
  public static void getMediaVolume(MethodCall call, Result result) {
    String userID = call.argument("userID");
    int volume = CloudroomVideoMeeting.getInstance().getMediaVolume();
    result.success(volume);
  }

  // 设置影音播放的音量 类型范围（0-255）
  public static void setMediaVolume(MethodCall call, Result result) {
    int volume = (int) call.argument("volume");
    CloudroomVideoMeeting.getInstance().setMediaVolume(volume);
    result.success(volume);
  }

  // 开始播放，如果不需要远端需要观看配合bLocPlay为true
  public static void startPlayMedia(MethodCall call, Result result) {
    String videoSrc = call.argument("videoSrc");
    boolean bLocPlay = (boolean) call.argument("bLocPlay");
    CloudroomVideoMeeting.getInstance().startPlayMedia(videoSrc, bLocPlay);
    result.success("");
  }

  //  暂停、继续播放
  public static void pausePlayMedia(MethodCall call, Result result) {
    boolean pause = (boolean) call.argument("pause");
    CloudroomVideoMeeting.getInstance().pausePlayMedia(pause);
    result.success(pause);
  }

  //  停止当前播放
  public static void stopPlayMedia(MethodCall call, Result result) {
    CloudroomVideoMeeting.getInstance().stopPlayMedia();
    result.success("");
  }

  // 设置播放进度
  public static void setMediaPlayPos(MethodCall call, Result result) {
    int pos = (int) call.argument("pos");
    CloudroomVideoMeeting.getInstance().setMediaPlayPos(pos);
    result.success(pos);
  }

  /**
   * 聊天
   */
  // 发送聊天消息
  public static void sendMeetingCustomMsg(MethodCall call, Result result) {
    String text = call.argument("text");
    String cookie = call.argument("cookie");
    // 发送聊天消息
    CloudroomVideoMeeting.getInstance().sendMeetingCustomMsg(text, cookie);
    result.success("");
  }

  /**
   * 通知
   */

  private static void notification(String method, Map map) {
    if (eventSink != null) {
      map.put("method", method);
      eventSink.success(map);
    } else {
      Log.e(TAG, "sink == null");
    }
  }

  private static void notification(String method) {
    if (eventSink != null) {
      Map map = new HashMap();
      map.put("method", method);
      eventSink.success(map);
    } else {
      Log.e(TAG, "sink == null");
    }
  }

  private static CRMgrCallback mMgrCallback = new CRMgrCallback() {
    // 登陆成功
    @Override
    public void loginSuccess(String userID, String cookie) {
      Map result = new HashMap();
      result.put("userID", userID);
      result.put("cookie", cookie);
      notification("loginSuccess", result);
    }

    // 登陆失败
    @Override
    public void loginFail(CRVIDEOSDK_ERR_DEF sdkErr, String cookie) {
      Map result = new HashMap();
      result.put("sdkErr", sdkErr.value());
      result.put("cookie", cookie);
      notification("loginFail", result);
    }

    // 通知用户掉线
    @Override
    public void lineOff(CRVIDEOSDK_ERR_DEF sdkErr) {
      Map result = new HashMap();
      result.put("sdkErr", sdkErr.value());
      notification("lineOff", result);
    }

    // 创建会议成功
    @Override
    public void createMeetingSuccess(MeetInfo meetInfo, String cookie) {
      Map map = new HashMap();
      map.put("pubMeetUrl", meetInfo.pubMeetUrl);
      map.put("id", meetInfo.ID);
      map.put("cookie", cookie);
      notification("createMeetingSuccess", map);
    }

    // 创建会议失败
    @Override
    public void createMeetingFail(CRVIDEOSDK_ERR_DEF sdkErr, String cookie) {
      Map map = new HashMap();
      map.put("sdkErr", sdkErr.value());
      map.put("cookie", cookie);
      notification("createMeetingFail", map);
    }

    // 销毁房间
    @Override
    public void destroyMeetingRslt(CRVIDEOSDK_ERR_DEF sdkErr, String cookie) {
      Map map = new HashMap();
      map.put("sdkErr", sdkErr.value());
      map.put("cookie", cookie);
      notification("destroyMeetingRslt", map);
    }
  };

  private static CRMeetingCallback mMeetingCallback = new CRMeetingCallback() {
    /**
     * 进入会议结果
     * @param code
     */
    @Override
    public void enterMeetingRslt(CRVIDEOSDK_ERR_DEF sdkErr) {
      Map map = new HashMap();
      map.put("sdkErr", sdkErr.value());
      // map.put("cookie", cookie);
      notification("enterMeetingRslt", map);
    }

    // 某用户进入了房间
    @Override
    public void userEnterMeeting(String userID) {
      Map map = new HashMap();
      map.put("userID", userID);
      notification("userEnterMeeting", map);
    }

    // 某用户离开了房间
    @Override
    public void userLeftMeeting(String userID) {
      Map map = new HashMap();
      map.put("userID", userID);
      notification("userLeftMeeting", map);
    }

    // 设置房间成员昵称的结果
    @Override
    public void setNickNameRsp(
      CRVIDEOSDK_ERR_DEF sdkErr,
      String userID,
      String newName
    ) {
      Map map = new HashMap();
      map.put("userID", userID);
      map.put("newName", newName);
      map.put("sdkErr", sdkErr.value());
      notification("setNickNameRsp", map);
    }

    // 某用户改变了昵称(改昵称的用户自身不会接收到此通知)
    @Override
    public void notifyNickNameChanged(
      String userID,
      String oldName,
      String newName
    ) {
      Map map = new HashMap();
      map.put("userID", userID);
      map.put("oldName", oldName);
      map.put("newName", newName);
      notification("notifyNickNameChanged", map);
    }

    // 通知从房间里掉线了
    @Override
    public void meetingDropped(CRVIDEOSDK_MEETING_DROPPED_REASON reason) {
      Map map = new HashMap();
      map.put("reason", reason.value());
      notification("meetingDropped", map);
    }

    // // 房间已被结束
    // @Override
    // public void meetingStoped() {
    //   Map map = new HashMap();
    //   notification("meetingStoped", map);
    // }

    // 网络变化通知
    @Override
    public void netStateChanged(int level) {
      Map map = new HashMap();
      map.put("level", level);
      notification("netStateChanged", map);
    }

    @Override
    public void openVideoRslt(String devID, boolean success) {
      // TODO Auto-generated method stub
      Map map = new HashMap();
      map.put("deviceID", devID);
      map.put("success", success);
      notification("openVideoRslt", map);
    }

    // 通知摄像头状态变化
    @Override
    public void videoStatusChanged(
      String userID,
      VSTATUS oldStatus,
      VSTATUS newStatus
    ) {
      Map map = new HashMap();
      map.put("userID", userID);
      map.put("oldStatus", oldStatus.value());
      map.put("newStatus", newStatus.value());
      notification("videoStatusChanged", map);
    }

    @Override
    public void videoDevChanged(String userID) {
      // TODO Auto-generated method stub
      Map map = new HashMap();
      map.put("userID", userID);
      notification("videoDevChanged", map);
    }

    // 通知音频状态变化
    @Override
    public void audioStatusChanged(
      String userID,
      ASTATUS oldStatus,
      ASTATUS newStatus
    ) {
      Map map = new HashMap();
      map.put("userID", userID);
      map.put("oldStatus", oldStatus.value());
      map.put("newStatus", newStatus.value());
      notification("audioStatusChanged", map);
    }

    @Override
    public void audioDevChanged() {
      notification("audioDevChanged");
    }

    // 通知用户的说话声音强度更新
    @Override
    public void micEnergyUpdate(String userID, int oldLevel, int newLevel) {
      Map map = new HashMap();
      map.put("userID", userID);
      map.put("oldLevel", oldLevel);
      map.put("newLevel", newLevel);
      notification("micEnergyUpdate", map);
    }

    // 开启屏幕共享
    @Override
    public void startScreenShareRslt(CRVIDEOSDK_ERR_DEF sdkErr) {
      Map map = new HashMap();
      map.put("sdkErr", sdkErr.value());
      notification("startScreenShareRslt", map);
    }

    // 停止屏幕共享
    @Override
    public void stopScreenShareRslt(CRVIDEOSDK_ERR_DEF sdkErr) {
      Map map = new HashMap();
      map.put("sdkErr", sdkErr.value());
      Log.e("stopScreenShareRslt", "" + sdkErr.value());
      notification("stopScreenShareRslt", map);
    }

    // 通知开启屏幕共享
    @Override
    public void notifyScreenShareStarted() {
      notification("notifyScreenShareStarted");
    }

    // 通知停止屏幕共享
    @Override
    public void notifyScreenShareStopped() {
      notification("notifyScreenShareStopped");
    }

    // 开启屏幕共享标注
    @Override
    public void startScreenMarkRslt(CRVIDEOSDK_ERR_DEF sdkErr) {
      Map map = new HashMap();
      map.put("sdkErr", sdkErr.value());
      notification("startScreenMarkRslt", map);
    }

    // 停止屏幕共享标注
    @Override
    public void stopScreenMarkRslt(CRVIDEOSDK_ERR_DEF sdkErr) {
      Map map = new HashMap();
      map.put("sdkErr", sdkErr.value());
      notification("stopScreenMarkRslt", map);
    }

    // 通知开启屏幕共享标注
    @Override
    public void notifyScreenMarkStarted() {
      notification("notifyScreenMarkStarted");
    }

    // 通知停止屏幕共享标注
    @Override
    public void notifyScreenMarkStopped() {
      notification("notifyScreenMarkStopped");
    }

    /**
     * 录制
     */
    // 本地录制文件、本地直播信息通知
    @Override
    public void locMixerOutputInfo(
      String mixerID,
      String nameOrUrl,
      MixerOutputInfo outputInfo
    ) {
      Map map = new HashMap();
      map.put("mixerID", mixerID);
      map.put("nameOrUrl", nameOrUrl);
      Map data = new HashMap();
      data.put("duration", outputInfo.duration);
      data.put("errCode", outputInfo.errCode.value());
      data.put("state", outputInfo.state.value());
      data.put("fileSize", outputInfo.fileSize);
      String outputInfoJson = gson.toJson(data);
      map.put("outputInfo", outputInfoJson);
      notification("locMixerOutputInfo", map);
    }

    // 本地混图器状态变化通知
    public void locMixerStateChanged(String mixerID, MIXER_STATE state) {
      Map map = new HashMap();
      map.put("mixerID", mixerID);
      map.put("state", state.value());
      notification("locMixerStateChanged", map);
    }

    // 云端录制、云端直播状态变化通知
    @Override
    public void svrMixerStateChanged(
      String operatorID,
      MIXER_STATE state,
      CRVIDEOSDK_ERR_DEF sdkErr
    ) {
      Map map = new HashMap();
      map.put("operatorID", operatorID);
      map.put("state", state.value());
      map.put("sdkErr", sdkErr.value());
      notification("svrMixerStateChanged", map);
    }

    // 云端录制、云端直播内容变化通知
    @Override
    public void svrMixerCfgChanged() {
      notification("svrMixerCfgChanged");
    }

    // 云端录制文件、云端直播信息变化通知
    @Override
    public void svrMixerOutputInfo(MixerOutputInfo outputInfo) {
      Map map = new HashMap();
      map.put("outputInfo", gson.toJson(outputInfo));
      notification("svrMixerOutputInfo", map);
    }

    /**
     * 影音
     */
    // 通知影音文件打开
    @Override
    public void notifyMediaOpened(int totalTime, Size picSZ) {
      Map map = new HashMap();
      map.put("totalTime", totalTime);
      map.put("width", picSZ.width);
      map.put("height", picSZ.height);
      notification("notifyMediaOpened", map);
    }

    // 通知影音开始播放
    @Override
    public void notifyMediaStart(String userid) {
      Map map = new HashMap();
      map.put("userID", userid);
      notification("notifyMediaStart", map);
    }

    // 通知影音暂停播放
    @Override
    public void notifyMediaPause(String userid, boolean pause) {
      Map map = new HashMap();
      map.put("userID", userid);
      map.put("pause", pause);
      notification("notifyMediaPause", map);
    }

    // 通知影音播放停止
    @Override
    public void notifyMediaStop(String userid, MEDIA_STOP_REASON reason) {
      Map map = new HashMap();
      map.put("userID", userid);
      map.put("reason", reason.value());
      notification("notifyMediaStop", map);
    }

    //发送结果
    @Override
    public void sendMeetingCustomMsgRslt(
      CRVIDEOSDK_ERR_DEF sdkErr,
      String cookie
    ) {
      // TODO Auto-generated method stub
      Map map = new HashMap();
      map.put("sdkErr", sdkErr.value());
      map.put("cookie", cookie);
      notification("sendMeetingCustomMsgRslt", map);
    }

    // 聊天信息通知
    @Override
    public void notifyMeetingCustomMsg(String fromUserID, String text) {
      // 收到聊天消息
      Map map = new HashMap();
      map.put("fromUserID", fromUserID);
      map.put("text", text);
      notification("notifyMeetingCustomMsg", map);
    }
  };
}
