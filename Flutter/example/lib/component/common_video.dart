import 'package:cloudroomvideosdk/cloudroomvideosdk.dart';
import '/application/application.dart';

class CommonVideo {
  late Function _setState;
  bool _isOpenCamera = false; // 是否开启摄像头
  List<CrCameraInfo> _camerasInfo = [];
  CrCameraInfo? _defaultCameraInfo;

  bool get isOpenCamera => _isOpenCamera;
  bool get isFrontCamera =>
      _defaultCameraInfo?.cameraPosition == CR_CAMERA_POSITION.FRONT; // 是否前置摄像头
  CrCameraInfo? get defaultCameraInfo => _defaultCameraInfo;

  addSDKVideoObserver(ob) {
    _setState = ob.setState;
    CrSDK.on("videoStatusChanged", videoStatusChanged);
  }

  removeSDKVideoObserver() {
    _setState = () {};
    CrSDK.off("videoStatusChanged", videoStatusChanged);
  }

  // 监听视像头状态
  videoStatusChanged(CrVideoStatusChanged vsc) {
    String userId = GlobalConfig.instance.userID;
    if (vsc.userId == userId) {
      _setState(() => _isOpenCamera = vsc.newStatus == CR_VSTATUS.VOPEN);
    }
  }

  // 摄像头开关
  Future switchCamera(String userId, bool isOpenCamera) {
    _setState(() => _isOpenCamera = isOpenCamera);
    return isOpenCamera
        ? CrSDK.instance.openVideo(userId)
        : CrSDK.instance.closeVideo(userId);
  }

  // 获取用户所有的摄像头信息
  Future<List<CrCameraInfo>> getAllVideoInfo(String userId) {
    return CrSDK.instance.getAllVideoInfo(userId).then((camerasInfo) {
      _camerasInfo = camerasInfo;
      return camerasInfo;
    });
  }

  // 获取用户默认摄像头
  Future<int> getDefaultVideo(String userId) {
    return getAllVideoInfo(userId).then((List<CrCameraInfo> camerasInfo) {
      return CrSDK.instance.getDefaultVideo(userId).then((int videoID) {
        for (CrCameraInfo cInfo in camerasInfo) {
          if (cInfo.videoID == videoID) {
            _defaultCameraInfo = cInfo;
          }
        }
        return videoID;
      });
    });
  }

  // 切换前后摄像头
  void setDefaultVideo(String userId, CR_CAMERA_POSITION cameraPosition) {
    // 从摄像头信息中找到对应位置的摄像头
    for (int i = 0; i < _camerasInfo.length; i++) {
      CrCameraInfo item = _camerasInfo[i];
      if (item.cameraPosition == cameraPosition) {
        _setState(() {
          _defaultCameraInfo = item;
        });
        CrSDK.instance.setDefaultVideo(userId, item.videoID);
        break;
      }
    }
  }
}
