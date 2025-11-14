import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rtcsdk_demo/src/resources/styles.dart';

class CustomTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool? obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? textStyle;
  // final Color? backgroundColor;
  final TextInputType? keyboardType;
  final EdgeInsetsGeometry? contentPadding;
  final bool? isDense;
  final String? hintText;
  final TextStyle? hintStyle;
  final bool showClear;

  const CustomTextFormField({
    Key? key,
    this.controller,
    this.validator,
    this.obscureText,
    this.inputFormatters,
    this.textStyle,
    // this.backgroundColor,
    this.keyboardType,
    this.contentPadding,
    this.isDense,
    this.hintText,
    this.hintStyle,
    this.showClear = true,
  }) : super(key: key);

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  Color borderColor = PageStyle.borderColor;
  bool isCanClear = false;
  late FocusNode focusNode;
  late TextEditingController controller;

  @override
  initState() {
    focusNode = FocusNode();
    controller = widget.controller ?? TextEditingController();
    controller.addListener(onChange);
    focusNode.addListener(onChange);
    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(onChange);
    focusNode.removeListener(onChange);
    if (widget.controller == null) {
      controller.dispose();
    }
    focusNode.dispose();
    super.dispose();
  }

  void onChange() {
    setState(() {
      isCanClear = focusNode.hasFocus && controller.text.isNotEmpty;
    });
  }

  void clear() {
    widget.controller?.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: widget.keyboardType,
              obscureText: widget.obscureText ?? false, // 输入框内容是否掩码
              style: widget.textStyle ??
                  const TextStyle(
                    color: PageStyle.c666666,
                    height: 1.2,
                  ), // 输入的样式
              textAlignVertical: TextAlignVertical.top,
              cursorColor: PageStyle.mainColor,
              inputFormatters: widget.inputFormatters,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: widget.hintStyle,
                isDense: widget.isDense,
                contentPadding: widget.contentPadding,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: InputBorder.none,
                // enabledBorder: const OutlineInputBorder(
                //   borderSide: BorderSide(
                //     color: PageStyle.borderColor,
                //   ),
                // ),
                // focusedBorder: const OutlineInputBorder(
                //   borderSide: BorderSide(
                //     color: PageStyle.mainColor,
                //   ),
                // ),
                // errorBorder: const OutlineInputBorder(
                //   borderSide: BorderSide(
                //     color: Colors.red,
                //   ),
                // ),
                // focusedErrorBorder: const OutlineInputBorder(
                //   borderSide: BorderSide(
                //     color: Colors.red,
                //   ),
                // ),
              ),
              validator: widget.validator,
            ),
          ),
          if (widget.showClear && isCanClear)
            IconButton(
              icon: Icon(
                Icons.cancel_sharp,
                size: 20.sp,
                color: PageStyle.c999999,
              ),
              onPressed: clear,
            )
        ],
      ),
    );
  }
}
