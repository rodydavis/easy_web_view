import 'dart:io';

import 'package:flutter/material.dart';

import 'platforms/android.dart';
import 'platforms/ios.dart';
import 'platforms/markdown.dart';
import 'platforms/widgets.dart';
import 'platforms/windows.dart';

class EasyWebView extends StatelessWidget {
  const EasyWebView({
    Key? key,
    required this.src,
    this.height,
    this.width,
    this.onLoaded,
    this.isMarkdown = false,
    this.convertToMarkdown = false,
    this.convertToWidgets = false,
  }) : super(key: key);

  final String src;
  final double? width, height;
  final void Function()? onLoaded;
  final bool isMarkdown;
  final bool convertToMarkdown;
  final bool convertToWidgets;

  @override
  Widget build(BuildContext context) {
    if (convertToWidgets) {
      return WidgetsWebView(
        src: src,
        width: width,
        height: height,
        onLoaded: onLoaded,
      );
    }
    if (isMarkdown || convertToMarkdown) {
      return MarkdownWebView(
        src: src,
        height: height,
        width: width,
        onLoaded: onLoaded,
      );
    }
    if (Platform.isIOS) {
      return IosWebView(
        src: src,
        width: width,
        height: height,
        onLoaded: onLoaded,
      );
    }
    if (Platform.isAndroid) {
      return AndroidWebView(
        src: src,
        width: width,
        height: height,
        onLoaded: onLoaded,
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
    return Placeholder();
  }
}
