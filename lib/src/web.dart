// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:easy_web_view/easy_web_view.dart';
import 'package:flutter/material.dart';

import 'impl.dart';

class EasyWebView extends StatefulWidget implements EasyWebViewImpl {
  const EasyWebView({
    Key? key,
    required this.src,
    required this.onLoaded,
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
  @override
  void initState() {
    widget.onLoaded();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final _iframe = _iframeElementMap[widget.key];
      _iframe?.onLoad.listen((event) {
        widget.onLoaded();
      });
    });
    super.initState();
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
              key: widget.key,
              viewType: 'iframe-$src',
            ),
          ),
        );
      },
    );
  }

  static final _iframeElementMap = Map<Key, html.IFrameElement>();

  void _setup(String? src, double width, double height) {
    final key = widget.key ?? ValueKey('');
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('iframe-$src', (int viewId) {
      if (_iframeElementMap[key] == null) {
        _iframeElementMap[key] = html.IFrameElement();
      }
      final element = _iframeElementMap[widget.key];

      element!
        ..style.border = '0'
        ..allowFullscreen = widget.webAllowFullScreen
        ..height = height.toInt().toString()
        ..width = width.toInt().toString();

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
      if (src != null) {
        if (widget.isMarkdown) {
          _src = "data:text/html;charset=utf-8," +
              Uri.encodeComponent(EasyWebViewImpl.md2Html(src));
        }
        if (widget.isHtml) {
          _src = "data:text/html;charset=utf-8," +
              Uri.encodeComponent(EasyWebViewImpl.wrapHtml(src));
        }
      }
      element..src = _src;
      return element;
    });
  }
}
