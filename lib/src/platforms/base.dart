import 'dart:async';

import 'package:flutter/services.dart';
import 'package:webview_windows/webview_windows.dart'
    show WebviewPopupWindowPolicy;

import 'package:flutter/material.dart';

import '../impl.dart';

abstract class WebView extends StatefulWidget {
  const WebView({
    Key? key,
    required this.src,
    required this.width,
    required this.height,
    required this.onLoaded,
  }) : super(key: key);

  final String src;
  final double? width, height;
  final void Function()? onLoaded;
}

class WebViewState<T extends WebView> extends State<T> {
  @override
  void didUpdateWidget(T oldWidget) {
    if (oldWidget.src != widget.src ||
        oldWidget.height != widget.height ||
        oldWidget.width != widget.width) {
      if (mounted) setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return OptionalSizedChild(
      width: widget.width,
      height: widget.height,
      builder: (w, h) => builder(context, Size(w, h), widget.src),
    );
  }

  Widget builder(BuildContext context, Size size, String contents) {
    return Placeholder();
  }
}

enum WebNavigationDecision { navigate, prevent }

class WebNavigationRequest {
  WebNavigationRequest(this.url);

  final String url;
}

typedef FutureOr<WebNavigationDecision> WebNavigationDelegate(
    WebNavigationRequest webNavigationRequest);

class CrossWindowEvent {
  final String name;
  final Function(dynamic) eventAction;

  CrossWindowEvent({
    required this.name,
    required this.eventAction,
  });
}

class WebViewOptions {
  final WebNavigationDelegate? navigationDelegate;
  final List<CrossWindowEvent> crossWindowEvents;
  final BrowserWebViewOptions browser;
  final NativeWebViewOptions native;
  final WindowsWebViewOptions windows;

  const WebViewOptions({
    this.navigationDelegate,
    this.crossWindowEvents = const [],
    this.browser = const BrowserWebViewOptions(),
    this.native = const NativeWebViewOptions(),
    this.windows = const WindowsWebViewOptions(),
  });
}

class NativeWebViewOptions {
  const NativeWebViewOptions({
    this.convertToWidgets = false,
    this.isMarkdown = false,
    this.isHtml = false,
    this.headers,
    this.widgetsTextSelectable = false,
  });

  final bool convertToWidgets;
  final bool isMarkdown;
  final bool isHtml;
  final Map<String, String>? headers;
  final bool widgetsTextSelectable;
}

class BrowserWebViewOptions {
  final bool allowFullScreen;
  final String? allow;

  const BrowserWebViewOptions({
    this.allowFullScreen = false,
    this.allow,
  });
}

class WindowsWebViewOptions {
  const WindowsWebViewOptions({
    this.popupWindowPolicy = WebviewPopupWindowPolicy.deny,
    this.backgroundColor = Colors.transparent,
    this.onUrlChanged,
    this.onError,
    this.userDataPath,
    this.browserExePath,
    this.additionalArguments,
  });

  final WebviewPopupWindowPolicy popupWindowPolicy;
  final Color backgroundColor;
  final void Function(String)? onUrlChanged;
  final void Function(PlatformException)? onError;
  final String? userDataPath;
  final String? browserExePath;
  final String? additionalArguments;
}
