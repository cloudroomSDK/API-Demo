import 'package:rtcsdk_demo/src/resources/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool? obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final Color? backgroundColor;
  const CustomTextFormField(
      {Key? key,
      this.controller,
      this.validator,
      this.obscureText,
      this.inputFormatters,
      this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText ?? false, // 输入框内容是否掩码
      style: TextStyle(
        backgroundColor: backgroundColor,
        color: PageStyle.c666666,
      ), // 输入的样式
      cursorColor: PageStyle.mainColor,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 15.w),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: PageStyle.borderColor,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: PageStyle.mainColor,
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
          ),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
          ),
        ),
      ),
      validator: validator,
    );
  }
}
