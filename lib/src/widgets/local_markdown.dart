import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class LocalMarkdown extends StatelessWidget {
  final String data;
  final MarkdownOptions options;

  const LocalMarkdown({
    required this.data,
    this.options = const MarkdownOptions(),
  });

  @override
  Widget build(BuildContext context) {
    return render(context, data);
  }

  Widget render(BuildContext context, String data) {
    return Markdown(
      data: data,
      onTapLink: (_, url, __) => onTapLink(context, url),
      selectable: options.selectable,
    );
  }

  void onTapLink(BuildContext, String? url) {
    if (url == null) {
      return;
    }
    if (options.onTapLink != null) {
      options.onTapLink!(url);
      return;
    }
    launch(url);
  }
}

class MarkdownOptions {
  const MarkdownOptions({
    this.selectable = false,
    this.headers = const {},
    this.convertToMarkdown,
    this.convertToHtml,
    this.onTapLink,
  });

  final bool selectable;
  final String Function(String)? convertToMarkdown;
  final String Function(String)? convertToHtml;
  final void Function(String)? onTapLink;
  final Map<String, String> headers;
}
