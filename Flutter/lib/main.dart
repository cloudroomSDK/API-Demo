import 'dart:async';
import 'dart:io';

import 'package:cloudroomvideosdk/cloudroomvideosdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart'
    show getExternalStorageDirectory, getApplicationDocumentsDirectory;
import 'package:fluro/fluro.dart';

import 'application/routes.dart';
import 'application/application.dart';
import 'application/connectivitys.dart';

void main() {
  // 强制竖屏
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(App());
  EasyLoading.instance
    ..maskColor = Colors.black.withOpacity(0.5)
    ..dismissOnTap = false;
}

class App extends StatefulWidget {
  App({Key? key}) : super(key: key) {
    final FluroRouter router = FluroRouter();
    Routes.configureRoutes(router);
    Application.router = router;
  }

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App>
    with CrSDKNotifier, WidgetsBindingObserver, Connectivitys {
  Size _designSize = const Size(375, 668);

  @override
  void initState() {
    Wakelock.enable();
    addCrNotifierListener([
      NOTIFIER_EVENT.lineOff,
    ]);
    connectivityInit();
    WidgetsBinding.instance?.addObserver(this);
    _getPermission();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    disposeCrNotifierListener();
    connectivityDispose();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    screenUtilInit();
    super.didChangeMetrics();
  }

  @override
  lineOff(int sdkErr) {
    GlobalConfig.instance.loginStatus = LOGIN_STATUS.unlogin;
    Application.emit("changeLoginStatus");
  }

  @override
  void connectivityConnect() {
    if (GlobalConfig.instance.initStatus != INIT_STATUS.init) {
      sdkInit();
    }
  }

  @override
  void connectivityDisconnect() {
    EasyLoading.showToast("没有网络");
  }

  _getPermission() async {
    await getStoragePermission();
    await getManageExternalStoragePermission();
    await getCameraPermission();
    await getMicrophonePermission();
  }

  // 检查存储权限 没有就去请求存储权限
  Future<bool> getStoragePermission() async {
    PermissionStatus storageStatus = await Permission.storage.status;
    bool _isStoragePermissionGranted =
        storageStatus == PermissionStatus.granted;
    if (!_isStoragePermissionGranted) {
      storageStatus = await Permission.storage.request();
    }
    return _isStoragePermissionGranted;
  }

  Future<bool> getManageExternalStoragePermission() async {
    PermissionStatus manageExternalStatus =
        await Permission.manageExternalStorage.status;
    bool _isManageExternalPermissionGranted =
        manageExternalStatus == PermissionStatus.granted;
    if (!_isManageExternalPermissionGranted) {
      manageExternalStatus = await Permission.manageExternalStorage.request();
    }
    return _isManageExternalPermissionGranted;
  }

  // 检查相机权限，没有就去请求相机权限
  Future<bool> getCameraPermission() async {
    PermissionStatus cameraStatus = await Permission.microphone.status;
    bool _isCameraPermissionGranted = cameraStatus == PermissionStatus.granted;
    if (!_isCameraPermissionGranted) {
      cameraStatus = await Permission.camera.request();
      _isCameraPermissionGranted = cameraStatus == PermissionStatus.granted;
    }
    return _isCameraPermissionGranted;
  }

  // 检查麦克风权限，没有就去请求麦克风权限
  Future<bool> getMicrophonePermission() async {
    PermissionStatus microphoneStatus = await Permission.microphone.status;
    bool _isMicrophonePermissionGranted =
        microphoneStatus == PermissionStatus.granted;
    if (!_isMicrophonePermissionGranted) {
      microphoneStatus = await Permission.microphone.request();
      _isMicrophonePermissionGranted =
          microphoneStatus == PermissionStatus.granted;
    }
    return _isMicrophonePermissionGranted;
  }

  Future<String> _getStorageDirectory() {
    if (Platform.isIOS) {
      return getApplicationDocumentsDirectory()
          .then((Directory? dir) => dir?.path ?? "");
    }
    return getExternalStorageDirectory().then((Directory? dir) {
      String? path = dir?.path;
      String dirPath =
          path != null ? path.split("/").sublist(0, 4).join("/") : "";
      return "$dirPath/CloudroomFlutter";
    });
  }

  sdkInit() async {
    final String path = await _getStorageDirectory();
    GlobalConfig.instance.sdkDatSavePath = path;
    CrSdkInitDat sdkInitDat =
        CrSdkInitDat(sdkDatSavePath: path, noCall: true, noQueue: true);
    final sdkErr = await CrSDK.instance.init(sdkInitDat);
    if (sdkErr == 0) {
      GlobalConfig.instance.initStatus = INIT_STATUS.init;
      await CrSDK.instance.setServerAddr(GlobalConfig.instance.serverAddr);
    }
  }

  screenUtilInit() {
    if (!mounted) return;
    Size? size = WidgetsBinding.instance?.window.physicalSize;
    double? physicalSizeWidth = size?.width;
    double? physicalSizeHeight = size?.height;
    if (physicalSizeWidth != null && physicalSizeHeight != null) {
      final bool isVertical =
          physicalSizeHeight.toInt() > physicalSizeWidth.toInt();
      setState(() {
        _designSize = isVertical ? const Size(375, 668) : const Size(668, 375);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: _designSize,
        builder: () => MaterialApp(
              title: 'CloudRoom',
              theme: ThemeData(
                brightness: Brightness.light,
                primaryColor: Colors.white,
                appBarTheme: const AppBarTheme(
                  centerTitle: true,
                  color: Colors.white,
                  titleTextStyle: TextStyle(color: Colors.black, fontSize: 18),
                  shadowColor: Colors.transparent,
                  iconTheme: IconThemeData(color: Colors.black),
                ),
              ),
              initialRoute: '/',
              onGenerateRoute: Application.router.generator,
              builder: EasyLoading.init(),
            ));
  }
}
