import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../extensions.dart';
import '../widgets/remote_content.dart';
import 'base.dart';

class MarkdownWebView extends WebView {
  MarkdownWebView({
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
  State<WebView> createState() => MarkdownState();
}

class MarkdownState extends WebViewState<MarkdownWebView> {
  @override
  Widget builder(BuildContext context, Size size, String contents) {
    final options = widget.options;
    if (widget.src.isValidUrl) {
      // TODO: Check for markdown files from assets
      // TODO: Check for markdown files form file system
      return RemoteContent(
        src: widget.src,
        headers: options.markdown.headers,
        builder: (context, contents) {
          String content = contents;
          if (widget.src.isValidHtml) {
            if (options.markdown.convertToMarkdown != null) {
              content = options.markdown.convertToMarkdown!(content);
            } else {
              content = content.toMarkdown();
            }
          }
          return renderMarkdown(context, content);
        },
      );
    }
    return renderMarkdown(context, widget.src);
  }

  Widget renderMarkdown(BuildContext context, String data) {
    final options = widget.options.markdown;
    return Markdown(
      data: data,
      onTapLink: (_, url, __) => options.onTapLink?.call(url),
      selectable: options.selectable,
    );
  }
}
