// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
// ignore: deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;       // platformViewRegistry lives here now
import 'package:flutter/material.dart';

import 'base.dart';
import 'platforms/base.dart';

class EasyWebView extends EasyWebViewBase {
  const EasyWebView({
    Key? key,
    required String src,
    double? height,
    double? width,
    OnLoaded? onLoaded,
    bool isMarkdown = false,
    bool convertToMarkdown = false,
    bool convertToWidgets = false,
    WidgetBuilder? fallbackBuilder,
    WebViewOptions options = const WebViewOptions(),
  }) : super(
          key: key,
          src: src,
          height: height,
          width: width,
          onLoaded: onLoaded,
          isMarkdown: isMarkdown,
          convertToMarkdown: convertToMarkdown,
          convertToWidgets: convertToWidgets,
          fallbackBuilder: fallbackBuilder,
          options: options,
        );

  @override
  Widget build(BuildContext context) {
    if (!canBuild()) {
      return BrowserWebView(
        key: key,
        src: src,
        width: width,
        height: height,
        onLoaded: onLoaded,
        options: options,
      );
    }
    return super.build(context);
  }
}

class BrowserWebView extends WebView {
  const BrowserWebView({
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
  State<StatefulWidget> createState() => BrowserWebViewState();
}

class BrowserWebViewState extends WebViewState<BrowserWebView> {
  static final _iframeElementMap = <Key?, html.IFrameElement>{};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final iframe = _iframeElementMap[widget.key];
      iframe?.onLoad.listen((_) {
        widget.onLoaded?.call(EasyWebViewControllerWrapper._(iframe));
      });
    });
  }

  void setup(String? src, double width, double height) {
    final key = widget.key ?? const ValueKey('');
    final viewType = 'iframe-${key.hashCode}';

    // using ui_web.platformViewRegistry for Flutter 3.32+
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      _iframeElementMap.putIfAbsent(key, () => html.IFrameElement());
      final element = _iframeElementMap[key]!;
      final opts = widget.options.browser;

      element
        ..style.border = '0'
        ..allowFullscreen = opts.allowFullScreen
        ..allow = opts.allow
        ..height = height.toInt().toString()
        ..width = width.toInt().toString()
        ..src = src ?? '';

      html.window.addEventListener('beforeunload', (event) async {
        final e = event as html.BeforeUnloadEvent;
        final delegate = widget.options.navigationDelegate;
        if (delegate == null) return;

        final decision =
        await delegate(WebNavigationRequest(html.window.location.href));

        if (decision == WebNavigationDecision.prevent) {
          e.preventDefault();
          e.returnValue = '';
        } else {
          e.returnValue = null;
        }
      });

      if (widget.options.crossWindowEvents.isNotEmpty) {
        html.window.addEventListener('message', (event) {
          final data = (event as html.MessageEvent).data;
          for (final cw in widget.options.crossWindowEvents) {
            cw.eventAction(data);
          }
        });
      }

      return element;
    });

    scheduleMicrotask(() {
      if (mounted) setState(() => _loaded = true);
    });
  }

  @override
  Widget builder(BuildContext context, Size size, String contents) {
    if (!_loaded) {
      setup(widget.src, size.width, size.height);
    }
    final viewType = 'iframe-${(widget.key ?? const ValueKey('')).hashCode}';
    return AbsorbPointer(
      child: RepaintBoundary(
        child: HtmlElementView(
          key: widget.key,
          viewType: viewType,
        ),
      ),
    );
  }
}

class EasyWebViewControllerWrapper extends EasyWebViewControllerWrapperBase {
  final html.IFrameElement _iframe;

  EasyWebViewControllerWrapper._(this._iframe);

  @override
  Future<void> evaluateJSMobile(String js) =>
      Future.error(UnsupportedError("the platform doesn't support this operation"));

  @override
  Future<String> evaluateJSWithResMobile(String js) =>
      Future.error(UnsupportedError("the platform doesn't support this operation"));

  @override
  Object get nativeWrapper => _iframe;

  @override
  void postMessageWeb(dynamic message, String targetOrigin) =>
      _iframe.contentWindow?.postMessage(message, targetOrigin);
}