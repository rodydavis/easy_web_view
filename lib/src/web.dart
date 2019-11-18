import 'package:easy_web_view/src/impl.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:html' as html;

class EasyWebView extends StatefulWidget implements EasyWebViewImpl {
  const EasyWebView({
    Key key,
    @required this.src,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  _EasyWebViewState createState() => _EasyWebViewState();

  @override
  final num height;

  @override
  final String src;

  @override
  final num width;
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
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return OptionalSizedChild(
      width: widget?.width,
      height: widget?.height,
      builder: (w, h) {
        final src = widget.src;
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

  void _setup(String src, num width, num height) {
    final src = widget.src;
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('iframe-$src', (int viewId) {
      final element = html.IFrameElement()
        ..style.border = '0'
        ..height = height.toInt().toString()
        ..width = width.toInt().toString();
      if (src != null) {
        element..src = src;
      }
      return element;
    });
  }
}
