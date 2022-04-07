import 'package:easy_web_view/easy_web_view.dart';
import 'package:example/ui/html_to_pdf/html_to_pdf.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  EasyWebViewControllerWrapperBase? _controller;
  EasyWebViewControllerWrapperBase? _controller2;
  EasyWebViewControllerWrapperBase? _controller3;
  String src = 'https://flutter.dev';
  String src2 = 'https://flutter.dev/community';
  String src3 = 'http://www.youtube.com/embed/IyFZznAk69U';
  static ValueKey key = ValueKey('key_0');
  static ValueKey key2 = ValueKey('key_1');
  static ValueKey key3 = ValueKey('key_2');
  bool _isHtml = false;
  bool _blockNavigation = false;
  bool _isMarkdown = false;
  bool _useWidgets = false;
  bool _editing = false;
  bool _isSelectable = false;
  bool _showSummernote = false;

  bool open = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Easy Web View'),
          leading: IconButton(
            icon: Icon(Icons.access_time),
            onPressed: () {
              setState(() {
                print("Click!");
                open = !open;
              });
            },

            //tooltip: "Menu",
          ),
          actions: <Widget>[
            Builder(builder: (context) {
              return IconButton(
                icon: Icon(_editing ? Icons.close : Icons.settings),
                onPressed: () {
                  if (mounted)
                    setState(() {
                      _editing = !_editing;
                    });
                },
              );
            }),
            if ((_isHtml || _isMarkdown) && _controller != null)
              IconButton(
                icon: Icon(Icons.print),
                onPressed: () async {
                  final _c = _controller!;
                  if (kIsWeb) {
                    _c.postMessageWeb('print', '*');
                  } else {
                    // await _c.evaluateJSMobile(js);
                  }
                },
              ),
            IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => HtmlToPdfTest(),
                ),
              ),
              icon: Icon(Icons.picture_as_pdf),
            ),
          ],
        ),
        body: _editing
            ? SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SwitchListTile(
                      title: Text('Html Content'),
                      value: _isHtml,
                      onChanged: (val) {
                        if (mounted)
                          setState(() {
                            _isHtml = val;
                            if (val) {
                              _isMarkdown = false;
                              src = htmlContent;
                            } else {
                              src = url;
                            }
                          });
                      },
                    ),
                    SwitchListTile(
                      title: Text('Block Html Navigation'),
                      value: _blockNavigation,
                      onChanged: (val) {
                        if (mounted)
                          setState(() {
                            _blockNavigation = val;
                          });
                      },
                    ),
                    SwitchListTile(
                      title: Text('Markdown Content'),
                      value: _isMarkdown,
                      onChanged: (val) {
                        if (mounted)
                          setState(() {
                            _isMarkdown = val;
                            if (val) {
                              _isHtml = false;
                              src = markdownContent;
                            } else {
                              src = url;
                            }
                          });
                      },
                    ),
                    SwitchListTile(
                      title: Text('Use Widgets'),
                      value: _useWidgets,
                      onChanged: (val) {
                        if (mounted)
                          setState(() {
                            _useWidgets = val;
                          });
                      },
                    ),
                    SwitchListTile(
                      title: Text('Selectable Text'),
                      value: _isSelectable,
                      onChanged: (val) {
                        if (mounted)
                          setState(() {
                            _isSelectable = val;
                          });
                      },
                    ),
                    SwitchListTile(
                      title: Text('Show Summernote'),
                      value: _showSummernote,
                      onChanged: (val) {
                        if (mounted)
                          setState(() {
                            _showSummernote = val;
                            if (val) {
                              _isMarkdown = false;
                              _isHtml = true;
                              src = summernoteHtml;
                            } else {
                              src = url;
                            }
                          });
                      },
                    ),
                  ],
                ),
              )
            : Stack(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                          flex: 1,
                          child: EasyWebView(
                            src: src,
                            onLoaded: (controller) {
                              setState(() {
                                _controller = controller;
                              });
                              print('$key: Loaded: $src');
                            },
                            isHtml: _isHtml,
                            isMarkdown: _isMarkdown,
                            convertToWidgets: _useWidgets,
                            key: key,
                            widgetsTextSelectable: _isSelectable,
                            webNavigationDelegate: (_) => _blockNavigation
                                ? WebNavigationDecision.prevent
                                : WebNavigationDecision.navigate,
                            crossWindowEvents: [
                              CrossWindowEvent(
                                name: 'Test',
                                eventAction: (eventMessage) {
                                  // print('Event message: $eventMessage');
                                },
                              ),
                            ],
                            // width: 100,
                            // height: 100,
                          )),
                      Expanded(
                        flex: 1,
                        child: EasyWebView(
                          onLoaded: (controller) {
                            setState(() {
                              _controller2 = controller;
                            });
                            print('$key2: Loaded: $src2');
                          },
                          src: src2,
                          isHtml: _isHtml,
                          isMarkdown: _isMarkdown,
                          convertToWidgets: _useWidgets,
                          widgetsTextSelectable: _isSelectable,
                          key: key2,
                          webNavigationDelegate: (_) => _blockNavigation
                              ? WebNavigationDecision.prevent
                              : WebNavigationDecision.navigate,
                          // width: 100,
                          // height: 100,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Container(),
                      ),
                      Expanded(
                          flex: 1,
                          child: Container(
                            width: (open) ? 500 : 0,
                            child: EasyWebView(
                                src: src3,
                                onLoaded: (controller) {
                                  setState(() {
                                    _controller3 = controller;
                                  });
                                  print('$key3: Loaded: $src3');
                                },
                                isHtml: _isHtml,
                                isMarkdown: _isMarkdown,
                                convertToWidgets: _useWidgets,
                                widgetsTextSelectable: _isSelectable,
                                key: key3
                                // width: 100,
                                // height: 100,
                                ),
                          )),
                    ],
                  )
                ],
              ));
  }

  String get htmlContent => """
<!DOCTYPE html>
<html>
<head>
<title>Page Title</title>
<script>
window.addEventListener("message", (message) => {
  console.log(message);
  if (message.data === "print") {
    window.print()
  }
})
</script>
</head>
<body>
<h1>This is a Heading</h1>
<p>This is a paragraph.</p>
</body>
</html>
""";

  String get markdownContent => """
<script>
window.addEventListener("message", (message) => {
  console.log(message);
  if (message.data === "print") {
    window.print()
  }
})
</script>
# This is a heading
## Here's a smaller heading
This is a paragraph
* Here's a bulleted list
* Another item
1. And an ordered list
1. The numbers don't matter
> This is a qoute
[This is a link to Flutter](https://flutter.dev)
""";

  String get embeedHtml => """
<iframe width="560" height="315" src="https://www.youtube.com/embed/rtBkU4pvHcw?controls=0" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
""";

  String get url => 'https://flutter.dev';

  String summernoteHtml = '''
<html>
  <head>
    <meta charset="UTF-8">
    <script src="https://code.jquery.com/jquery-3.4.1.slim.min.js" integrity="sha384-J6qa4849blE2+poT4WnyKhv5vZF5SrPo0iEjwBvKU7imGFAV0wwj1yYfoRSJoZ+n" crossorigin="anonymous"></script>
    <link href="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote-lite.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote-lite.min.js"></script>
  </head>
  <body>
    <div id="summernote"></div>
    <script>
    window.onload = function () {
      \$('#summernote').summernote({
        height: 400,
        tabsize: 2,
        callbacks: {
          onChange: function() {
            \$('#html-content').text(\$('#summernote').summernote('code'));
            
            window.parent.postMessage(\$('#summernote').summernote('code'), '*');
            if (window.Test != null) {
              window.Test.postMessage(\$('#summernote').summernote('code'));
            }
          }
        },
        toolbar: [
          ['style', ['style']],
          ['font', ['bold', 'underline', 'clear']],
          ['color', ['color']],
          ['para', ['ul', 'ol', 'paragraph']],
          ['table', ['table']],
          ['insert', ['link', 'picture']],
          ['view', ['codeview']]
        ]
      });
    }
    </script>
    <div id="html-content" style="display: none"></div>
  </body>
</html>
''';
}
