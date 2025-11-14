import 'package:rtcsdk_demo/src/controller/app_controller.dart';
import 'package:rtcsdk_demo/src/widgets/custom_appbar.dart';
import 'package:rtcsdk_demo/src/widgets/custom_text_formfield.dart';
import 'package:rtcsdk_demo/src/widgets/dividing_line.dart';
import 'package:rtcsdk_demo/src/widgets/touch_close_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rtcsdk_demo/src/resources/styles.dart';
import 'package:get/get.dart';
import 'joinroom_logic.dart';

class JoinRoom extends StatelessWidget {
  JoinRoom({Key? key}) : super(key: key);
  final appLogic = Get.find<AppController>();
  final logic = Get.find<JoinRoomLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const CustomAppBar(title: "加入房间"),
      body: TouchCloseSoftKeyboard(
        child: Container(
            color: PageStyle.cf2f2f2,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: 11.h),
              child: Container(
                  width: 1.sw,
                  padding:
                      EdgeInsets.symmetric(vertical: 28.h, horizontal: 27.w),
                  color: Colors.white,
                  child: Form(
                    key: logic.formKey,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: Text(
                                "请输入房间号：",
                                style: PageStyle.ts_14c999999,
                              )),
                          SizedBox(
                            height: 40.h,
                            child: CustomTextFormField(
                              controller: logic.confIdController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp('[0-9]'))
                              ],
                              validator: logic.validator,
                            ),
                          ),

                          // 进入房间按钮
                          Container(
                            margin: EdgeInsets.only(top: 28.5.h),
                            width: double.infinity,
                            height: 40.h,
                            child: ElevatedButton(
                                style: PageStyle.getButtonStyle(
                                  textStyle: PageStyle.ts_16cffffff,
                                ),
                                onPressed: logic.tapEnterRoom,
                                child: Text(
                                  "进入房间",
                                  style: PageStyle.ts_14cffffff,
                                )),
                          ),

                          Container(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: DividingLine(
                                child: Text(
                              "或者",
                              style: PageStyle.ts_14c999999,
                            )),
                          ),

                          // 创建房间按钮
                          SizedBox(
                            width: double.infinity,
                            height: 40.h,
                            child: ElevatedButton(
                              style: PageStyle.getButtonStyle(
                                textStyle: PageStyle.ts_16cffffff,
                              ),
                              onPressed: logic.createRoom,
                              child: Text(
                                "创建房间",
                                style: PageStyle.ts_14cffffff,
                              ),
                            ),
                          ),
                          // ...logic.tips
                        ]),
                  )),
            )),
      ),
    );
  }
}
