import 'package:flutter/material.dart';

import 'platforms/base.dart';
import 'platforms/markdown.dart';
import 'platforms/widgets.dart';

abstract class EasyWebViewBase extends StatelessWidget {
  const EasyWebViewBase({
    Key? key,
    required this.src,
    required this.width,
    required this.height,
    required this.onLoaded,
    required this.isMarkdown,
    required this.convertToMarkdown,
    required this.convertToWidgets,
    required this.fallbackBuilder,
    required this.options,
  }) : super(key: key);

  final String src;
  final double? width, height;
  final OnLoaded? onLoaded;
  final bool isMarkdown;
  final bool convertToMarkdown;
  final bool convertToWidgets;
  final WidgetBuilder? fallbackBuilder;
  final WebViewOptions options;

  bool canBuild() {
    if (convertToWidgets) return true;
    if (isMarkdown || convertToMarkdown) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (canBuild()) {
      if (convertToWidgets) {
        return WidgetsWebView(
          key: key,
          src: src,
          width: width,
          height: height,
          onLoaded: onLoaded,
          options: options,
        );
      }

      if (isMarkdown || convertToMarkdown) {
        return MarkdownWebView(
          key: key,
          src: src,
          height: height,
          width: width,
          onLoaded: onLoaded,
          options: options,
        );
      }
    }
    if (fallbackBuilder != null) {
      return fallbackBuilder!(context);
    } else {
      return Placeholder();
    }
  }
}
