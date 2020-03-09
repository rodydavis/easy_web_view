import 'package:easy_web_view/src/impl.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:html' as html;

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class EasyWebView extends StatefulWidget implements EasyWebViewImpl {
  const EasyWebView({
    Key key,
    @required this.src,
    this.height,
    this.width,
    this.webAllowFullScreen = true,
    this.isHtml = false,
    this.isMarkdown = false,
    this.convertToWidets = false,
    this.headers = const {},
  })  : assert((isHtml && isMarkdown) == false),
        super(key: key);

  @override
  _EasyWebViewState createState() => _EasyWebViewState();

  @override
  final num height;

  @override
  final String src;

  @override
  final num width;

  @override
  final bool webAllowFullScreen;

  @override
  final bool isMarkdown;

  @override
  final bool isHtml;

  @override
  final bool convertToWidets;

  @override
  final Map<String, String> headers;
}

class _EasyWebViewState extends State<EasyWebView> {
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
      width: widget?.width,
      height: widget?.height,
      builder: (w, h) {
        String src = widget.src;
        if (widget.convertToWidets) {
          if (EasyWebViewImpl.isUrl(src)) {
            return RemoteMarkdown(
              src: src,
              headers: widget.headers,
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
          return LocalMarkdown(data: _markdown);
        }
        _setup(src, w, h);
        return AbsorbPointer(
          child: HtmlElementView(
            key: widget?.key,
            viewType: 'iframe-$src',
          ),
        );
      },
    );
  }

  static html.IFrameElement _iframeElement = html.IFrameElement();

  void _setup(String src, num width, num height) {
    final src = widget.src;
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('iframe-$src', (int viewId) {
      final element = _iframeElement
        ..style.border = '0'
        ..allowFullscreen = widget.webAllowFullScreen
        ..height = height.toInt().toString()
        ..width = width.toInt().toString();
      if (src != null) {
        String _src = src;
        if (widget.isMarkdown) {
          _src = "data:text/html;charset=utf-8," +
              Uri.encodeComponent(EasyWebViewImpl.md2Html(src));
        }
        if (widget.isHtml) {
          _src = "data:text/html;charset=utf-8," +
              Uri.encodeComponent(EasyWebViewImpl.wrapHtml(src));
        }
        element..src = _src;
      }
      return element;
    });
  }

  Widget _buildMarkdown(String src) {
    return Markdown(
      data: src,
      onTapLink: launch,
    );
  }
}
