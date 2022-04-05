import 'package:flutter/material.dart';

import '../extensions.dart';
import '../widgets/local_markdown.dart';
import '../widgets/remote_markdown.dart';
import 'base.dart';

class MarkdownWebView extends WebView {
  MarkdownWebView({
    required String src,
    required double? width,
    required double? height,
    required void Function()? onLoaded,
    this.options = const MarkdownOptions(),
  }) : super(
          src: src,
          width: width,
          height: height,
          onLoaded: onLoaded,
        );

  final MarkdownOptions options;

  @override
  State<WebView> createState() => MarkdownState();
}

class MarkdownState extends WebViewState<MarkdownWebView> {
  @override
  Widget builder(BuildContext context, Size size, String contents) {
    if (contents.isValidUrl) {
      return RemoteMarkdown(
        src: contents,
        options: widget.options,
      );
    } else {
      return LocalMarkdown(
        data: contents,
        options: widget.options,
      );
    }
  }
}
