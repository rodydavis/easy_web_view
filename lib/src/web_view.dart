import 'dart:io';

import 'package:flutter/material.dart';

import 'platforms/native.dart';
import 'platforms/windows.dart';
import 'web_view_base.dart';

class EasyWebView extends EasyWebViewBase {
  const EasyWebView({
    Key? key,
    required this.src,
    this.height,
    this.width,
    this.onLoaded,
    this.isMarkdown = false,
    this.convertToMarkdown = false,
    this.convertToWidgets = false,
    this.fallbackBuilder,
  }) : super(
          src: src,
          height: height,
          width: width,
          onLoaded: onLoaded,
          isMarkdown: isMarkdown,
          convertToMarkdown: convertToMarkdown,
          convertToWidgets: convertToWidgets,
          fallbackBuilder: fallbackBuilder,
        );

  final String src;
  final double? width, height;
  final void Function()? onLoaded;
  final bool isMarkdown;
  final bool convertToMarkdown;
  final bool convertToWidgets;
  final WidgetBuilder? fallbackBuilder;

  @override
  Widget build(BuildContext context) {
    if (!canBuild()) {
      if (Platform.isIOS || Platform.isAndroid) {
        return NativeWebView(
          src: src,
          width: width,
          height: height,
          onLoaded: onLoaded,
          options: const NativeWebViewOptions(),
        );
      }

      if (Platform.isWindows) {
        return WindowsWebView(
          src: src,
          width: width,
          height: height,
          onLoaded: onLoaded,
        );
      }
    }
    return super.build(context);
  }
}
