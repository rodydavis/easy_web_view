import 'package:flutter/material.dart';

import '../impl.dart';

abstract class WebView extends StatefulWidget {
  const WebView({
    Key? key,
    required this.src,
    required this.width,
    required this.height,
    required this.onLoaded,
  }) : super(key: key);

  final String src;
  final double? width, height;
  final void Function()? onLoaded;
}

class WebViewState<T extends WebView> extends State<T> {
  @override
  void didUpdateWidget(T oldWidget) {
    if (oldWidget.src != widget.src ||
        oldWidget.height != widget.height ||
        oldWidget.width != widget.width) {
      if (mounted) setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return OptionalSizedChild(
      width: widget.width,
      height: widget.height,
      builder: (w, h) => builder(context, Size(w, h), widget.src),
    );
  }

  Widget builder(BuildContext context, Size size, String contents) {
    return Placeholder();
  }
}
