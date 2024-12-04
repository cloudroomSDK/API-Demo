import 'package:flutter/material.dart';
import 'package:rtcsdk_demo/src/widgets/custom_text_formfield.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rtcsdk_demo/src/controller/app_controller.dart';
import 'package:rtcsdk_demo/src/resources/styles.dart';
import 'package:rtcsdk_demo/src/routes/navigator.dart';
import 'package:rtcsdk_demo/src/widgets/touch_close_keyboard.dart';
import 'setting_logic.dart';

class Settings extends StatelessWidget {
  Settings({Key? key}) : super(key: key);
  final appLogic = Get.find<AppController>();
  final logic = Get.find<SettingsLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("设置"),
          leading: const IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: AppNavigator.back,
          ),
          actions: [
            GestureDetector(
                onTap: logic.saveAppConfig,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: 10.w,
                  ),
                  child: Text(
                    "保存",
                    style: PageStyle.ts_14c3981fc,
                  ),
                ))
          ],
        ),
        body: TouchCloseSoftKeyboard(
            child: Container(
                color: PageStyle.cf2f2f2,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(top: 11.h),
                  child: Column(
                    children: [
                      Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 27.w, vertical: 28.5.h),
                          child: Form(
                              key: logic.formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                      padding: EdgeInsets.only(bottom: 10.h),
                                      child: const Text("服务器地址 :",
                                          style: TextStyle(
                                              color: PageStyle.c666666))),
                                  CustomTextFormField(
                                    controller: logic.serverAddrController,
                                    validator: (value) {
                                      return logic.validator(
                                          value, "serverAddr");
                                    },
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(
                                          top: 20.h, bottom: 10.h),
                                      child: const Text("APP ID ：",
                                          style: TextStyle(
                                              color: PageStyle.c666666))),
                                  CustomTextFormField(
                                    controller: logic.appIdController,
                                    validator: (value) {
                                      return logic.validator(value, "appId");
                                    },
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(
                                          top: 20.h, bottom: 10.h),
                                      child: const Text("APP Secret :",
                                          style: TextStyle(
                                              color: PageStyle.c666666))),
                                  CustomTextFormField(
                                    controller: logic.appSecretController,
                                    obscureText: true,
                                    validator: (value) {
                                      return logic.validator(
                                          value, "appSecret");
                                    },
                                  ),
                                ],
                              ))),
                      Container(
                        margin: EdgeInsets.only(top: 45.h),
                        padding: EdgeInsets.only(
                          left: 27.w,
                          right: 27.w,
                        ),
                        width: double.infinity,
                        height: 40.h,
                        child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(PageStyle.mainColor),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(5.0))),
                            ),
                            onPressed: logic.resetAppConfig,
                            child: Text(
                              "恢复默认",
                              style: PageStyle.ts_14cffffff,
                            )),
                      ),
                    ],
                  ),
                ))));
  }
}
