import 'package:rtcsdk_demo/src/controller/rtc_controller.dart';
import 'package:rtcsdk_demo/src/controller/permission_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:focus_detector/focus_detector.dart';

import 'routes/pages.dart';
import 'routes/router.dart';
import 'utils/logger_util.dart';
import 'controller/app_controller.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
        init: AppController(),
        builder: (controller) => FocusDetector(
            onForegroundGained: () => controller.runningBackground(false),
            onForegroundLost: () => controller.runningBackground(true),
            child: ScreenUtilInit(
              designSize: const Size(375, 668),
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (_, __) => GetMaterialApp(
                debugShowCheckedModeBanner: true,
                enableLog: true,
                builder: EasyLoading.init(
                    builder: (BuildContext context, Widget? widget) {
                  EasyLoading.instance
                    ..maskColor = Colors.black.withOpacity(0.5)
                    ..dismissOnTap = false;
                  return widget!;
                }),
                theme: ThemeData(
                  brightness: Brightness.light,
                  primaryColor: Colors.white,
                  appBarTheme: const AppBarTheme(
                    centerTitle: true,
                    color: Colors.white,
                    titleTextStyle:
                        TextStyle(color: Colors.black, fontSize: 18),
                    shadowColor: Colors.transparent,
                    iconTheme: IconThemeData(color: Colors.black),
                  ),
                ),
                logWriterCallback: Logger.print,
                getPages: AppPages.routes,
                initialBinding: InitialBinding(),
                initialRoute: AppRoutes.FUNCTIONS,
              ),
            )));
  }
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<PermissionController>(PermissionController());
    Get.put<AppController>(AppController());
    Get.put<RTCController>(RTCController());
  }
}
