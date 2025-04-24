import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PageStyle {
  static const Color mainColor = Color(0xff3981fc);
  static const Color dangerColor = Color(0xfff00000);
  static const Color cffffff = Color(0xffffffff);
  static const Color cf0f0f0 = Color(0xfff0f0f0);
  static const Color cf2f2f2 = Color(0xfff2f2f2);
  static const Color c333333 = Color(0xff333333);
  static const Color c444444 = Color(0xff444444);
  static const Color c666666 = Color(0xff666666);
  static const Color c999999 = Color(0xff999999);
  static const Color c1d232f = Color(0xff1D232F);
  static const Color cff4e4e = Color(0xfff44e4e);
  static const Color c1D232F = Color(0xff1D232F);
  static const Color cB1B1B1 = Color(0xffB1B1B1);

  static const Color backgroundColor1 = Color(0xff1D232F);
  // 不get .sp 太快使用有问题
  static TextStyle get ts_12c333333 => TextStyle(
        fontSize: 12.sp,
        color: c333333,
      );
  static TextStyle get ts_14c333333 => TextStyle(
        fontSize: 14.sp,
        color: c333333,
      );
  static TextStyle get ts_16c333333 => TextStyle(
        fontSize: 16.sp,
        color: c333333,
      );

  static TextStyle get ts_12c666666 => TextStyle(
        fontSize: 12.sp,
        color: c666666,
      );
  static TextStyle get ts_14c666666 => TextStyle(
        fontSize: 14.sp,
        color: c666666,
      );
  static TextStyle get ts_16c666666 => TextStyle(
        fontSize: 16.sp,
        color: c666666,
      );

  static TextStyle get ts_12c999999 => TextStyle(
        fontSize: 12.sp,
        color: c999999,
      );
  static TextStyle get ts_14c999999 => TextStyle(
        fontSize: 14.sp,
        color: c999999,
      );
  static TextStyle get ts_16c999999 => TextStyle(
        fontSize: 16.sp,
        color: c999999,
      );

  static TextStyle get ts_12cffffff => TextStyle(
        fontSize: 12.sp,
        color: cffffff,
      );
  static TextStyle get ts_14cffffff => TextStyle(
        fontSize: 14.sp,
        color: cffffff,
      );
  static TextStyle get ts_16cffffff => TextStyle(
        fontSize: 16.sp,
        color: cffffff,
      );

  static TextStyle get ts_12c3981fc => TextStyle(
        fontSize: 12.sp,
        color: mainColor,
      );
  static TextStyle get ts_14c3981fc => TextStyle(
        fontSize: 14.sp,
        color: mainColor,
      );
  static TextStyle get ts_16c3981fc => TextStyle(
        fontSize: 16.sp,
        color: mainColor,
      );

  static const Color borderColor = Color(0xffd2d2d2);

  static const BoxBorder underline = BorderDirectional(
    bottom: BorderSide(color: PageStyle.borderColor, width: 0.5),
  );

  // ElevatedButton.styleFrom
  // 这样写所有按钮都能用
  static ButtonStyle getButtonStyle({
    TextStyle? textStyle,
    double? borderRadius,
    Color? backgroundColor,
    EdgeInsets? padding,
  }) {
    return ButtonStyle(
      textStyle: MaterialStateProperty.all(textStyle ?? ts_14cffffff),
      backgroundColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        Color col = backgroundColor ?? mainColor;
        if (states.contains(MaterialState.disabled)) {
          return col.withOpacity(0.6);
        }
        return col;
      }),
      shape: MaterialStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 5.0))),
      padding: MaterialStateProperty.all(padding ?? EdgeInsets.zero),
    );
  }

  static ButtonStyle getDangerButtonStyle({
    TextStyle? textStyle,
    double? borderRadius,
    EdgeInsets? padding,
  }) {
    return getButtonStyle(
      textStyle: textStyle,
      borderRadius: borderRadius,
      backgroundColor: dangerColor,
      padding: padding,
    );
  }
}
