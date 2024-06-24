import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as wv;

import 'base.dart';

class NativeWebView extends WebView {
  const NativeWebView({
    required Key? key,
    required String src,
    required double? width,
    required double? height,
    required OnLoaded? onLoaded,
    required this.options,
  }) : super(
          key: key,
          src: src,
          width: width,
          height: height,
          onLoaded: onLoaded,
        );

  final WebViewOptions options;

  @override
  State<WebView> createState() => NativeWebViewState();
}

class EasyWebViewControllerWrapper extends EasyWebViewControllerWrapperBase {
  final wv.WebViewController _controller;

  EasyWebViewControllerWrapper._(this._controller);

  @override
  Future<void> evaluateJSMobile(String js) {
    return _controller.runJavaScript(js);
  }

  @override
  Future<String> evaluateJSWithResMobile(String js) async {
    final result = await _controller.runJavaScriptReturningResult(js);
    return jsonEncode(result);
  }

  @override
  Object get nativeWrapper => _controller;

  @override
  void postMessageWeb(dynamic message, String targetOrigin) =>
      throw UnsupportedError("the platform doesn't support this operation");
}

class NativeWebViewState extends WebViewState<NativeWebView> {
  late wv.WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = wv.WebViewController()
      ..setJavaScriptMode(wv.JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        wv.NavigationDelegate(
          onPageFinished: (url) {
            if (widget.onLoaded != null) {
              widget.onLoaded!(EasyWebViewControllerWrapper._(controller));
            }
          },
          onNavigationRequest: (request) async {
            if (widget.options.navigationDelegate == null) {
              return wv.NavigationDecision.navigate;
            }
            final _navDecision = await widget //
                .options
                .navigationDelegate!(WebNavigationRequest(request.url));
            return _navDecision == WebNavigationDecision.prevent
                ? wv.NavigationDecision.prevent
                : wv.NavigationDecision.navigate;
          },
        ),
      );
    for (final event in widget.options.crossWindowEvents) {
      controller.addJavaScriptChannel(
        event.name,
        onMessageReceived: (javascriptMessage) {
          event.eventAction(javascriptMessage.message);
        },
      );
    }
  }

  @override
  void didUpdateWidget(covariant NativeWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.src != widget.src) {
      reload();
    }
  }

  reload() {
    final uri = Uri.parse(url);
    controller.loadRequest(uri);
  }

  @override
  Widget builder(BuildContext context, Size size, String contents) {
    return wv.WebViewWidget(
      key: widget.key,
      controller: controller,
    );
  }
}
