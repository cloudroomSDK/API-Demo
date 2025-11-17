import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rtcsdk_demo/src/resources/styles.dart';

enum DialogType {
  confirm,
}

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    Key? key,
    this.title,
    this.titleStyle,
    this.child,
    this.url,
    this.content,
    this.contentStyle,
    this.rightText,
    this.rightTextStyle,
    this.leftText,
    this.leftTextStyle,
    this.onTapLeft,
    this.onTapRight,
    this.hideLeftButton = false,
    this.hideRightButton = false,
  }) : super(key: key);
  final String? title;
  final TextStyle? titleStyle;
  final Widget? child;
  final String? url;
  final String? content;
  final TextStyle? contentStyle;
  final String? rightText;
  final TextStyle? rightTextStyle;
  final String? leftText;
  final TextStyle? leftTextStyle;
  final Function()? onTapLeft;
  final Function()? onTapRight;
  final bool hideLeftButton;
  final bool hideRightButton;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            width: 280.w,
            color: PageStyle.cffffff,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 20.h,
                    ),
                    child: Column(
                      children: [
                        Text(
                          title ?? '',
                          style: titleStyle ?? PageStyle.ts_16c333333,
                        ),
                        if (content != null)
                          Padding(
                            padding: EdgeInsets.only(top: 10.h),
                            child: Text(
                              content ?? '',
                              style: titleStyle ?? PageStyle.ts_14c333333,
                            ),
                          ),
                      ],
                    )),
                if (child != null) Container(child: child),
                Divider(
                  color: PageStyle.ce8eaef,
                  height: 0.5.h,
                ),
                Row(
                  children: [
                    if (!hideLeftButton)
                      _button(
                        bgColor: PageStyle.cffffff,
                        text: leftText ?? "取消",
                        textStyle: PageStyle.ts_14c333333,
                        onTap: onTapLeft ?? () => Get.back(result: false),
                      ),
                    if (!hideLeftButton && !hideRightButton)
                      Container(
                        color: PageStyle.ce8eaef,
                        width: 0.5.w,
                        height: 48.h,
                      ),
                    if (!hideRightButton)
                      _button(
                        bgColor: PageStyle.cffffff,
                        text: rightText ?? "确认",
                        textStyle: rightTextStyle ?? PageStyle.ts_14c3981fc,
                        onTap: onTapRight ?? () => Get.back(result: true),
                      ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _button({
    required Color bgColor,
    required String text,
    required TextStyle textStyle,
    Function()? onTap,
  }) =>
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
            ),
            height: 48.h,
            alignment: Alignment.center,
            child: Text(
              text,
              style: textStyle,
            ),
          ),
        ),
      );
}
