import 'package:flutter/material.dart';
import 'package:html2md/html2md.dart' as html2md;

import '../extensions.dart';
import 'local_markdown.dart';
import 'remote_content.dart';

class RemoteMarkdown extends LocalMarkdown {
  const RemoteMarkdown({
    required this.src,
    this.options = const MarkdownOptions(),
  }) : super(data: src, options: options);

  final String src;
  final MarkdownOptions options;

  @override
  Widget build(BuildContext context) {
    // TODO: Check for markdown files from assets
    // TODO: Check for markdown files form file system
    return RemoteContent(
      src: src,
      headers: options.headers,
      builder: (context, contents) {
        String content = contents;
        if (src.isValidHtml) {
          if (options.convertToMarkdown != null) {
            content = options.convertToMarkdown!(content);
          } else {
            content = html2md.convert(content);
          }
        }
        return super.render(context, content);
      },
    );
  }
}
