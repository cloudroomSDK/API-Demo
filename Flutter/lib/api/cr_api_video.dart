import 'dart:convert';

import '/api/cr_api.dart';
import '/implements/cr_impl.dart';
import '/implements/cr_impl_video.dart';
import '/cr_defines.dart';

extension CrVideoApi on CrSDK {
  
  // 获取摄像头参数配置
  Future<CrVideoCfg> getVideoCfg() async {
    final String result = await CrImpl.instance.getVideoCfg();
    Map data = json.decode(result);
    return CrVideoCfg(
        size: CrSize(
            width: data["size"]["width"], height: data["size"]["height"]),
        fps: data["fps"],
        maxbps: data["maxbps"],
        qp_min: data["qp_min"],
        qp_max: data["qp_max"]);
  }

  // 设置摄像头参数配置
  Future<void> setVideoCfg(CrVideoCfg cfg) async {
    String cfgJson = json.encode(cfg.toJson());
    return await CrImpl.instance.setVideoCfg(cfgJson);
  }

  // 获取用户所有的摄像头信息
  Future<List<CrCameraInfo>> getAllVideoInfo(String userID) async {
    final String result = await CrImpl.instance.getAllVideoInfo(userID);
    List items = json.decode(result);
    List<CrCameraInfo> cameraInfo = items.map((data) {
      String videoName = data["videoName"];
      String userId = data["userId"];
      int videoID = data["videoID"];
      return CrCameraInfo(
          userId: userId,
          videoID: videoID,
          videoName: videoName,
          cameraPosition:
              videoName.contains(RegExp(r'front', caseSensitive: false))
                  ? CR_CAMERA_POSITION.FRONT
                  : CR_CAMERA_POSITION.BACK);
    }).toList();
    return cameraInfo;
  }

  // 获取指定用户的默认摄像头 ，如果用户没有摄像头，返回0
  Future<int> getDefaultVideo(String userID) async {
    return await CrImpl.instance.getDefaultVideo(userID);
  }

  // 设置默认的摄像头 ，videoID 应该从getAllVideoInfo返回值中获取
  Future<void> setDefaultVideo(String userID, int videoID) async {
    return await CrImpl.instance.setDefaultVideo(userID, videoID);
  }

  // 获取房间内所有可观看的摄像头
  Future<List<CrUsrVideoId>> getWatchableVideos() async {
    final String result = await CrImpl.instance.getWatchableVideos();
    List items = json.decode(result);
    List<CrUsrVideoId> usrVideoIds = items.map((item) {
      CrUsrVideoId usrVideoId =
          CrUsrVideoId(userId: item["userId"], videoID: item["videoID"]);
      return usrVideoId;
    }).toList();
    return usrVideoIds;
  }

  // 打开用户的摄像头，以便本地、远端显示视频图像
  Future<CrOpenVideoResult> openVideo(String userID) async {
    final Map result = await CrImpl.instance.openVideo(userID);
    return CrOpenVideoResult(
        deviceID: result["deviceID"], success: result["success"]);
  }

  // 关闭用户的摄像头
  Future<void> closeVideo(String userID) async {
    return await CrImpl.instance.closeVideo(userID);
  }

  // 开始预览
  Future<void> setUsrVideoId(viewID, CrUsrVideoId usrVideoId) async {
    return await CrImpl.instance
        .setUsrVideoId(viewID, json.encode(usrVideoId.toJson()));
  }

  // 获取视频比例
  Future<int> getScaleType(int viewID) async {
    return await CrImpl.instance.getScaleType(viewID);
  }

  // 设置视频比例
  Future<void> setScaleType(int viewID, int scaleType) async {
    return await CrImpl.instance.setScaleType(viewID, scaleType);
  }
}
