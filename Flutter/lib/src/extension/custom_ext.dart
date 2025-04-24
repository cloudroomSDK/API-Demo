// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

extension StrExt on String {
  TextView get toText {
    return TextView(this);
  }

  TextView get toTextEllipsis {
    return TextView(
      this,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  ImageView get toImage {
    return ImageView(
      name: this,
    );
  }

  // ElevatedButton get toElevatedButton {
  //   return  ElevatedButton(
  //       style: PageStyle.getButtonStyle(),
  //       onPressed: onPressed,
  //       child: child,
  //     ) TextView(data: this);
  // }
}

class TextView extends StatelessWidget {
  TextView(
    this.data, {
    Key? key,
    this.style,
    this.textAlign,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
  }) : super(key: key);

  final String data;
  TextStyle? style;
  TextAlign? textAlign;
  TextOverflow? overflow;
  double? textScaleFactor;
  int? maxLines;

  @override
  Widget build(BuildContext context) => Text(
        data,
        style: style,
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxLines,
      );
}

class ImageView extends StatelessWidget {
  ImageView({
    super.key,
    required this.name,
    this.package,
    this.width,
    this.height,
    this.color,
    this.opacity = 1,
    this.fit,
    this.onTap,
    this.onDoubleTap,
  });
  final String name;
  String? package;
  double? width;
  double? height;
  Color? color;
  double opacity;
  BoxFit? fit;
  Function()? onTap;
  Function()? onDoubleTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        child: Opacity(
          opacity: opacity,
          child: Image.asset(
            name,
            package: package,
            width: width,
            height: height,
            color: color,
            fit: fit,
          ),
        ),
      );
}
