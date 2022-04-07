import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class RemoteContent extends StatelessWidget {
  const RemoteContent({
    required this.src,
    required this.builder,
    this.headers = const {},
  });

  final String src;
  final Map<String, String> headers;
  final Widget Function(BuildContext, String) builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<http.Response>(
      future: http.get(Uri.parse(src), headers: headers),
      builder: (context, response) {
        if (!response.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        if (response.data?.statusCode == 200 && response.data?.body != null) {
          String content = response.data!.body;
          return builder(context, content);
        }
        return Center(child: Icon(Icons.error));
      },
    );
  }
}
