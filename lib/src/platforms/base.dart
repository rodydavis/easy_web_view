import 'dart:async';

import 'package:flutter/services.dart';
import 'package:webview_windows/webview_windows.dart'
    show WebviewPopupWindowPolicy;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart'
    show
        WidgetFactory,
        CustomStylesBuilder,
        CustomWidgetBuilder,
        OnErrorBuilder,
        OnLoadingBuilder,
        ImageMetadata,
        RebuildTriggers,
        RenderMode;

import 'package:flutter/material.dart';

import '../extensions.dart';
import '../widgets/optionally_sized_child.dart';

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
  final OnLoaded? onLoaded;
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
      builder: (context, size) => builder(context, size, widget.src),
    );
  }

  Widget builder(BuildContext context, Size size, String contents) {
    return Placeholder();
  }

  String get url {
    return widget.src.toDataUrl();
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


typedef OnLoaded = void Function(EasyWebViewControllerWrapperBase controller);

abstract class EasyWebViewControllerWrapperBase {
  /// WebViewController on mobile, IFrameElement on web
  Object get nativeWrapper;

  Future<void> evaluateJSMobile(String js);
  Future<String> evaluateJSWithResMobile(String js);

  void postMessageWeb(dynamic message, String targetOrigin);
}

class WebViewOptions {
  final WebNavigationDelegate? navigationDelegate;
  final List<CrossWindowEvent> crossWindowEvents;
  final BrowserWebViewOptions browser;
  final NativeWebViewOptions native;
  final WindowsWebViewOptions windows;
  final MarkdownOptions markdown;
  final WidgetsWebViewOptions widgets;

  const WebViewOptions({
    this.navigationDelegate,
    this.crossWindowEvents = const [],
    this.browser = const BrowserWebViewOptions(),
    this.native = const NativeWebViewOptions(),
    this.windows = const WindowsWebViewOptions(),
    this.markdown = const MarkdownOptions(),
    this.widgets = const WidgetsWebViewOptions(),
  });
}

class MarkdownOptions {
  const MarkdownOptions({
    this.selectable = false,
    this.headers = const {},
    this.convertToMarkdown,
    this.convertToHtml,
    this.onTapLink,
  });

  final bool selectable;
  final String Function(String)? convertToMarkdown;
  final String Function(String)? convertToHtml;
  final void Function(String?)? onTapLink;
  final Map<String, String> headers;
}

class WidgetsWebViewOptions {
  const WidgetsWebViewOptions({
    this.buildAsync,
    this.factoryBuilder,
    this.baseUrl,
    this.customStylesBuilder,
    this.customWidgetBuilder,
    this.onErrorBuilder,
    this.onLoadingBuilder,
    this.onTapImage,
    this.onTapUrl,
    this.rebuildTriggers,
    this.textStyle,
    this.isSelectable = false,
    this.enableCaching = true,
    this.onSelectionChanged,
    this.renderMode = RenderMode.column,
  });

  final bool? buildAsync;
  final bool enableCaching;
  final WidgetFactory Function()? factoryBuilder;
  final bool isSelectable;
  final Uri? baseUrl;
  final CustomStylesBuilder? customStylesBuilder;
  final CustomWidgetBuilder? customWidgetBuilder;
  final OnErrorBuilder? onErrorBuilder;
  final OnLoadingBuilder? onLoadingBuilder;
  final SelectionChangedCallback? onSelectionChanged;
  final void Function(ImageMetadata)? onTapImage;
  final FutureOr<bool> Function(String)? onTapUrl;
  final RebuildTriggers? rebuildTriggers;
  final RenderMode renderMode;
  final TextStyle? textStyle;
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
