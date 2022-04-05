import 'package:flutter/material.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:http/http.dart' as http;

import '../extensions.dart';
import 'local_markdown.dart';

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
    return FutureBuilder<http.Response>(
      future: http.get(Uri.parse(src), headers: options.headers),
      builder: (context, response) {
        if (!response.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        if (response.data?.statusCode == 200 && response.data?.body != null) {
          String content = response.data!.body;
          if (src.isValidHtml) {
            if (options.convertToMarkdown != null) {
              content = options.convertToMarkdown!(content);
            } else {
              content = html2md.convert(content);
            }
          }
          return super.render(context, content);
        }
        return Center(child: Icon(Icons.error));
      },
    );
  }
}
