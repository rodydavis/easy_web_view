// ignore: avoid_web_libraries_in_flutter
import 'dart:developer';
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:easy_web_view/easy_web_view.dart';
import 'package:flutter/material.dart';

import 'impl.dart';

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
  late Key effectiveKey;

  // void testPrint(html.IFrameElement _iframe) {
  //   _iframe.focus();
  //   if (_iframe.srcdoc != null && _iframe.srcdoc!.isNotEmpty) {
  //     final window = _iframe.contentWindow;
  //     if (window != null) {
  //       window.postMessage('print', '*');
  //     }
  //   }
  //   log('iframe ready: ${_iframe.id}');
  // }

  @override
  void initState() {
    super.initState();
    effectiveKey = widget.key ?? ValueKey('');
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final _iframe = _iframeElementMap[effectiveKey];
      if (_iframe != null) {
        _iframe.onLoad.listen((event) {
          widget.onLoaded?.call(EasyWebViewControllerWrapper._(_iframe));
        });
      }
    });
  }

  @override
  void didUpdateWidget(EasyWebView oldWidget) {
    if (oldWidget.height != widget.height) {
      if (mounted) setState(() {});
    }
    if (oldWidget.width != widget.width) {
      if (mounted) setState(() {});
    }
    if (oldWidget.src != widget.src) {
      if (mounted) setState(() {});
    }
    if (oldWidget.headers != widget.headers) {
      if (mounted) setState(() {});
    }
    super.didUpdateWidget(oldWidget);
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
        _setup(src, w, h);
        return AbsorbPointer(
          child: RepaintBoundary(
            child: HtmlElementView(
              key: effectiveKey,
              viewType: 'iframe-$src',
            ),
          ),
        );
      },
    );
  }

  static final _iframeElementMap = Map<Key, html.IFrameElement>();

  void _setup(String? src, double width, double height) {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('iframe-$src', (int viewId) {
      final element = _iframeElementMap[effectiveKey] ??= html.IFrameElement();
      log('View Created: viewId: $viewId');

      element
            ..id = 'iframe-$viewId'
            ..style.border = '0'
            ..allowFullscreen = widget.webAllowFullScreen
            ..allow = widget.allow
            ..style.width = '100%'
            ..style.height = '100%'
          // ..height = height.toInt().toString()
          // ..width = width.toInt().toString()
          ;

      html.window.addEventListener('onbeforeunload', (event) async {
        final beforeUnloadEvent = (event as html.BeforeUnloadEvent);
        if (widget.webNavigationDelegate == null) return;
        final webNavigationDecision = await widget.webNavigationDelegate!(
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

      if (widget.crossWindowEvents.isNotEmpty) {
        html.window.addEventListener('message', (event) {
          final eventData = (event as html.MessageEvent).data;
          widget.crossWindowEvents.forEach((crossWindowEvent) {
            final crossWindowEventListener = crossWindowEvent.eventAction;
            crossWindowEventListener(eventData);
          });
        });
      }
      String _src = src ?? '';
      String? _srcDoc;
      if (src != null) {
        if (widget.isMarkdown) {
          _srcDoc = EasyWebViewImpl.md2Html(src);
          // _src = "data:text/html;charset=utf-8," + Uri.encodeComponent(_srcDoc);
        }
        if (widget.isHtml) {
          _srcDoc = EasyWebViewImpl.wrapHtml(src);
          // _src = "data:text/html;charset=utf-8," + Uri.encodeComponent(_srcDoc);
        }
      }

      if (_srcDoc != null) {
        element.srcdoc = _srcDoc;
      }
      element.src = _src;
      return element;
    });
  }
}
