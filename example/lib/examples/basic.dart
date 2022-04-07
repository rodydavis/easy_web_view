import 'package:easy_web_view/easy_web_view.dart';
import 'package:flutter/material.dart';

class BasicExample extends StatefulWidget {
  const BasicExample({Key? key}) : super(key: key);

  @override
  _BasicExampleState createState() => _BasicExampleState();
}

class _BasicExampleState extends State<BasicExample> {
  String src = 'https://flutter.dev';
  String src2 = 'https://flutter.dev/community';
  String src3 = 'http://www.youtube.com/embed/IyFZznAk69U';
  static ValueKey key = const ValueKey('key_0');
  static ValueKey key2 = const ValueKey('key_1');
  static ValueKey key3 = const ValueKey('key_2');
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
          title: const Text('Easy Web View'),
          leading: IconButton(
            icon: const Icon(Icons.access_time),
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
                  if (mounted) {
                    setState(() {
                      _editing = !_editing;
                    });
                  }
                },
              );
            }),
          ],
        ),
        body: _editing
            ? SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SwitchListTile(
                      title: const Text('Html Content'),
                      value: _isHtml,
                      onChanged: (val) {
                        if (mounted) {
                          setState(() {
                            _isHtml = val;
                            if (val) {
                              _isMarkdown = false;
                              src = htmlContent;
                            } else {
                              src = url;
                            }
                          });
                        }
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Block Html Navigation'),
                      value: _blockNavigation,
                      onChanged: (val) {
                        if (mounted) {
                          setState(() {
                            _blockNavigation = val;
                          });
                        }
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Markdown Content'),
                      value: _isMarkdown,
                      onChanged: (val) {
                        if (mounted) {
                          setState(() {
                            _isMarkdown = val;
                            if (val) {
                              _isHtml = false;
                              src = markdownContent;
                            } else {
                              src = url;
                            }
                          });
                        }
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Use Widgets'),
                      value: _useWidgets,
                      onChanged: (val) {
                        if (mounted) {
                          setState(() {
                            _useWidgets = val;
                          });
                        }
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Selectable Text'),
                      value: _isSelectable,
                      onChanged: (val) {
                        if (mounted) {
                          setState(() {
                            _isSelectable = val;
                          });
                        }
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Show Summernote'),
                      value: _showSummernote,
                      onChanged: (val) {
                        if (mounted) {
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
                        }
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
                            onLoaded: (_) {
                              print('$key: Loaded: $src');
                            },
                            isMarkdown: _isMarkdown,
                            convertToWidgets: _useWidgets,
                            key: key,
                          )),
                      Expanded(
                        flex: 1,
                        child: EasyWebView(
                          onLoaded: (_) {
                            print('$key2: Loaded: $src2');
                          },
                          src: src2,
                          key: key2,
                          isMarkdown: _isMarkdown,
                          convertToWidgets: _useWidgets,
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
                              onLoaded: (_) {
                                print('$key3: Loaded: $src3');
                              },
                              isMarkdown: _isMarkdown,
                              convertToWidgets: _useWidgets,
                              key: key3,
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
</head>
<body>
<h1>This is a Heading</h1>
<p>This is a paragraph.</p>
</body>
</html>
""";

  String get markdownContent => """
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
