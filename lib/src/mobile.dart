import 'dart:io';

import 'package:easy_web_view/easy_web_view.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'impl.dart';

class EasyWebView extends StatefulWidget implements EasyWebViewImpl {
  const EasyWebView({
    required this.src,
    required this.onLoaded,
    Key? key,
    this.height,
    this.width,
    this.webAllowFullScreen = true,
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
  final void Function() onLoaded;

  @override
  final List<CrossWindowEvent> crossWindowEvents;

  @override
  final WebNavigationDelegate? webNavigationDelegate;
}

class _EasyWebViewState extends State<EasyWebView> {
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();

    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  void didUpdateWidget(EasyWebView oldWidget) {
    if (oldWidget.src != widget.src) {
      _webViewController.loadUrl(_updateUrl(widget.src),
          headers: widget.headers);
    }
    if (oldWidget.height != widget.height) {
      if (mounted) setState(() {});
    }
    if (oldWidget.width != widget.width) {
      if (mounted) setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  String _updateUrl(String url) {
    String _src = url;
    if (widget.isMarkdown) {
      _src = "data:text/html;charset=utf-8," +
          Uri.encodeComponent(EasyWebViewImpl.md2Html(url));
    }
    if (widget.isHtml) {
      _src = "data:text/html;charset=utf-8," +
          Uri.encodeComponent(EasyWebViewImpl.wrapHtml(url));
    }
    widget.onLoaded();
    return _src;
  }

  @override
  Widget build(BuildContext context) {
    return OptionalSizedChild(
      width: widget.width,
      height: widget.height,
      builder: (w, h) {
        String src = widget.src;
        if (widget.convertToWidgets) {
          if (EasyWebViewImpl.isUrl(src)) {
            return RemoteMarkdown(
              src: src,
              headers: widget.headers,
              isSelectable: widget.widgetsTextSelectable,
            );
          }
          String _markdown = '';
          if (widget.isMarkdown) {
            _markdown = src;
          }
          if (widget.isHtml) {
            src = EasyWebViewImpl.wrapHtml(src);
            _markdown = EasyWebViewImpl.html2Md(src);
          }
          return LocalMarkdown(
            data: _markdown,
            isSelectable: widget.widgetsTextSelectable,
          );
        }
        return WebView(
          key: widget.key,
          initialUrl: _updateUrl(src),
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (webViewController) {
            _webViewController = webViewController;
            widget.onLoaded();
          },
          navigationDelegate: (navigationRequest) async {
            if (widget.webNavigationDelegate == null) {
              return NavigationDecision.navigate;
            }

            final webNavigationDecision = await widget.webNavigationDelegate!(
                WebNavigationRequest(navigationRequest.url));
            return (webNavigationDecision == WebNavigationDecision.prevent)
                ? NavigationDecision.prevent
                : NavigationDecision.navigate;
          },
          javascriptChannels: widget.crossWindowEvents.isNotEmpty
              ? widget.crossWindowEvents
                  .map(
                    (crossWindowEvent) => JavascriptChannel(
                      name: crossWindowEvent.name,
                      onMessageReceived: (javascriptMessage) => crossWindowEvent
                          .eventAction(javascriptMessage.message),
                    ),
                  )
                  .toSet()
              : Set<JavascriptChannel>(),
        );
      },
    );
  }
}
