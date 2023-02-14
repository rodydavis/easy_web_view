import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as wv;
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart'
    as wviOS;

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
    return (await _controller.runJavaScriptReturningResult(js)) as String;
  }

  @override
  Object get nativeWrapper => _controller;

  @override
  void postMessageWeb(dynamic message, String targetOrigin) =>
      throw UnsupportedError("the platform doesn't support this operation");
}

class NativeWebViewState extends WebViewState<NativeWebView> {
  late wv.WebViewController controller;

  wv.PlatformWebViewControllerCreationParams _buildControllerCreationParams() {
    if (wv.WebViewPlatform.instance is wviOS.WebKitWebViewPlatform) {
      return wviOS.WebKitWebViewControllerCreationParams();
    } else {
      return const wv.PlatformWebViewControllerCreationParams();
    }
  }

  /// Setup the controller with [JavaScriptMode], [NavigationDelegate] and
  /// add JavaScript channels passed in via options then load the request.
  wv.WebViewController _createController(
    wv.PlatformWebViewControllerCreationParams params,
  ) {
    final controller = wv.WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(wv.JavaScriptMode.unrestricted)
      ..setNavigationDelegate(wv.NavigationDelegate(
        onNavigationRequest: (navigationRequest) async {
          if (widget.options.navigationDelegate == null) {
            return wv.NavigationDecision.navigate;
          }
          final _navDecision = await widget.options
              .navigationDelegate!(WebNavigationRequest(navigationRequest.url));
          return _navDecision == WebNavigationDecision.prevent
              ? wv.NavigationDecision.prevent
              : wv.NavigationDecision.navigate;
        },
      ));

    // Add javascript channels to the controller
    for (final event in widget.options.crossWindowEvents) {
      controller.addJavaScriptChannel(event.name,
          onMessageReceived: (javascriptMessage) {
        event.eventAction(javascriptMessage.message);
      });
    }

    // Load the initial url passed into the webview and return.
    return controller..loadRequest(Uri.parse(url));
  }

  @override
  void initState() {
    super.initState();

    final controllerCreationParams = _buildControllerCreationParams();
    controller = _createController(controllerCreationParams);
    widget.onLoaded?.call(EasyWebViewControllerWrapper._(controller));
  }

  @override
  void didUpdateWidget(covariant NativeWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.src != widget.src) {
      reload();
    }
  }

  reload() {
    controller.loadRequest(Uri.parse(url));
  }

  @override
  Widget builder(BuildContext context, Size size, String contents) {
    return wv.WebViewWidget(
      key: widget.key,
      controller: controller,
    );
  }
}
