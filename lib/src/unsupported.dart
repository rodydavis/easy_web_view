import 'package:easy_web_view/easy_web_view.dart';
import 'package:flutter/material.dart';

import 'impl.dart';

class EasyWebView extends StatefulWidget implements EasyWebViewImpl {
  const EasyWebView({
    Key? key,
    required this.src,
    this.onLoaded,
    this.height,
    this.width,
    this.webAllowFullScreen = true,
    this.allow = "",
    this.isHtml = false,
    this.isMarkdown = false,
    this.convertToWidgets = false,
    this.headers = const {},
    this.widgetsTextSelectable = false,
    this.crossWindowEvents = const [],
    this.webNavigationDelegate,
  })  : assert((isHtml && isMarkdown) == false),
        super(key: key);

  @override
  _EasyWebViewState createState() => _EasyWebViewState();

  @override
  final double? height;

  @override
  final String src;

  @override
  final double? width;

  @override
  final bool webAllowFullScreen;

  @override
  final String allow;

  @override
  final bool isMarkdown;

  @override
  final bool isHtml;

  @override
  final bool convertToWidgets;

  @override
  final Map<String, String> headers;

  @override
  final bool widgetsTextSelectable;

  @override
  final OnLoaded? onLoaded;

  @override
  final List<CrossWindowEvent> crossWindowEvents;

  @override
  final WebNavigationDelegate? webNavigationDelegate;
}

class _EasyWebViewState extends State<EasyWebView> {
  @override
  Widget build(BuildContext context) {
    return OptionalSizedChild(
      width: widget.width,
      height: widget.height,
      builder: (w, h) => Placeholder(),
    );
  }
}
