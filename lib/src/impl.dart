import 'package:flutter/material.dart';

class EasyWebViewImpl {
  final String src;
  final num width, height;
  final bool webAllowFullScreen;

  EasyWebViewImpl({
    @required this.src,
    this.width,
    this.height,
    this.webAllowFullScreen = true,
  });
}

class OptionalSizedChild extends StatelessWidget {
  final num width, height;
  final Widget Function(num, num) builder;

  const OptionalSizedChild({
    Key key,
    @required this.width,
    @required this.height,
    @required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (width == null || height == null) {
      return LayoutBuilder(
        builder: (context, dimens) {
          final w = width ?? dimens.maxWidth;
          final h = height ?? dimens.maxHeight;
          return SizedBox(
            width: w,
            height: h,
            child: builder(w, h),
          );
        },
      );
    }
    return SizedBox(
      width: width,
      height: height,
      child: builder(width, height),
    );
  }
}
