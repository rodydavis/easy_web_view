// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'base.dart';

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
  static final _iframeElementMap = Map<Key, html.IFrameElement>();
  bool _loaded = false;

  @override
  void initState() {
    // ignore: invalid_null_aware_operator
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final _iframe = _iframeElementMap[widget.key];
      _iframe?.onLoad.listen((event) {
        widget.onLoaded?.call(EasyWebViewControllerWrapper._(_iframe));
      });
    });
    super.initState();
  }

  void setup(String? src, double width, double height) {
    final key = widget.key ?? ValueKey('');
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('iframe-$url', (int viewId) {
      if (_iframeElementMap[key] == null) {
        _iframeElementMap[key] = html.IFrameElement();
      }
      final element = _iframeElementMap[widget.key];
      final options = widget.options.browser;

      element!
        ..style.border = '0'
        ..allowFullscreen = options.allowFullScreen
        ..allow = options.allow
        ..height = height.toInt().toString()
        ..width = width.toInt().toString();

      html.window.addEventListener('onbeforeunload', (event) async {
        final beforeUnloadEvent = (event as html.BeforeUnloadEvent);
        if (widget.options.navigationDelegate == null) return;
        final webNavigationDecision = await widget.options.navigationDelegate!(
            WebNavigationRequest(html.window.location.href));
        if (webNavigationDecision == WebNavigationDecision.prevent) {
          // Cancel the event
          beforeUnloadEvent.preventDefault();
          // Chrome requires returnValue to be set
          beforeUnloadEvent.returnValue = '';
        } else {
          // Guarantee the browser unload by removing the returnValue property of the event
          beforeUnloadEvent.returnValue = null;
        }
      });

      if (widget.options.crossWindowEvents.isNotEmpty) {
        html.window.addEventListener('message', (event) {
          final eventData = (event as html.MessageEvent).data;
          widget.options.crossWindowEvents.forEach((crossWindowEvent) {
            final crossWindowEventListener = crossWindowEvent.eventAction;
            crossWindowEventListener(eventData);
          });
        });
      }
      element..src = url;
      return element;
    });
    scheduleMicrotask(() {
      setState(() {
        _loaded = true;
      });
    });
  }

  @override
  Widget builder(BuildContext context, ui.Size size, String contents) {
    if (!_loaded) {
      setup(widget.src, size.width, size.height);
    }
    return AbsorbPointer(
      child: RepaintBoundary(
        child: HtmlElementView(
          key: widget.key,
          viewType: 'iframe-$url',
        ),
      ),
    );
  }
}

class EasyWebViewControllerWrapper extends EasyWebViewControllerWrapperBase {
  final html.IFrameElement _iframe;

  EasyWebViewControllerWrapper._(this._iframe);

  @override
  Future<void> evaluateJSMobile(String js) {
    throw UnsupportedError("the platform doesn't support this operation");
  }

  @override
  Future<String> evaluateJSWithResMobile(String js) {
    throw UnsupportedError("the platform doesn't support this operation");
  }

  @override
  Object get nativeWrapper => _iframe;

  @override
  void postMessageWeb(dynamic message, String targetOrigin) =>
      _iframe.contentWindow?.postMessage(message, targetOrigin);
}
