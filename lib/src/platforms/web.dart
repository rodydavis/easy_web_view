// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui' as ui;

import '../extensions.dart';
import 'package:flutter/material.dart';

import 'base.dart';

class BrowserWebView extends WebView {
  const BrowserWebView({
    required String src,
    required double? width,
    required double? height,
    required void Function()? onLoaded,
    required this.options,
  }) : super(
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

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final _iframe = _iframeElementMap[widget.key];
      _iframe?.onLoad.listen((event) {
        widget.onLoaded?.call();
      });
    });
    super.initState();
  }

  void setup(String? src, double width, double height) {
    final key = widget.key ?? ValueKey('');
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('iframe-$src', (int viewId) {
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
      element..src = widget.src.isValidUrl ? widget.src : widget.src.dataUrl;
      return element;
    });
  }

  @override
  Widget builder(BuildContext context, ui.Size size, String contents) {
    final dataUrl = widget.src.isValidUrl ? widget.src : widget.src.dataUrl;
    return AbsorbPointer(
      child: RepaintBoundary(
        child: HtmlElementView(
          key: widget.key,
          viewType: 'iframe-$dataUrl',
        ),
      ),
    );
  }
}
