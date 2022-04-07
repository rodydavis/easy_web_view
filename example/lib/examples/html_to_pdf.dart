import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';

import 'package:easy_web_view/easy_web_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:flutter/services.dart';

class HtmlToPdfTest extends StatefulWidget {
  const HtmlToPdfTest({Key? key}) : super(key: key);

  @override
  State<HtmlToPdfTest> createState() => _HtmlToPdfTestState();
}

class _HtmlToPdfTestState extends State<HtmlToPdfTest> {
  final _templateMemoizer = AsyncMemoizer<String>();
  EasyWebViewControllerWrapperBase? _controller;
  final _key = const ValueKey('test_html_to_pdf');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test HTML To PDF'),
        actions: [
          if (_controller != null)
            IconButton(
              onPressed: () async {
                final msg = {
                  'id': 'htmltopdf',
                  // 'width': 1024,
                  'format': [1000, 800]
                };
                if (kIsWeb) {
                  _controller!.postMessageWeb(msg, '*');
                } else {
                  _controller!
                      .evaluateJSMobile('htmlToPDF(${jsonEncode(msg)})');
                }
              },
              icon: const Icon(Icons.check_box),
            ),
        ],
      ),
      body: FutureBuilder<String>(
        future: _templateMemoizer.runOnce(
            () => rootBundle.loadString('assets/test_html_to_pdf.html')),
        builder: (context, snapshot) {
          final invoiceSrc = snapshot.data;
          if (invoiceSrc == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return EasyWebView(
            src: invoiceSrc,
            onLoaded: (controller) {
              setState(() {
                _controller = controller;
              });
            },
            key: _key,
            options: WebViewOptions(
              crossWindowEvents: [
                CrossWindowEvent(
                  name: 'ParentChannel',
                  eventAction: (eventMessage) async {
                    if (eventMessage is Map) {
                      final id = eventMessage['id'];
                      if (id == 'htmltopdf') {
                        final res = eventMessage['result'];
                        log(res.runtimeType.toString());
                        if (res is Uint8List) {
                          // final pdfResult = utf8.decode(res);
                          if (kIsWeb) {
                            await FileSaver.instance.saveFile(
                              'easy_web_view_invoice',
                              res,
                              'pdf',
                              mimeType: MimeType.PDF,
                            );
                          } else {
                            await FileSaver.instance.saveAs(
                              'easy_web_view_invoice',
                              res,
                              'pdf',
                              MimeType.PDF,
                            );
                          }

                          log(res.runtimeType.toString());
                        }
                      }
                    }
                    // log('Event message: $eventMessage');
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
