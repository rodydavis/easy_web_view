import 'package:flutter/material.dart';

class OptionalSizedChild extends StatelessWidget {
  final double? width, height;
  final Widget Function(BuildContext, Size) builder;

  const OptionalSizedChild({
    required this.width,
    required this.height,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, dimens) {
        final w = width ?? dimens.maxWidth;
        final h = height ?? dimens.maxHeight;
        return SizedBox(
          width: w,
          height: h,
          child: builder(context, Size(w, h)),
        );
      },
    );
  }
}
