# example

A new Flutter project.

## Example

```dart
import 'package:easy_web_view/easy_web_view.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String src = 'https://flutter.dev';
  bool _isHtml = false;
  bool _isMarkdown = false;
  bool _useWidgets = false;
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Easy Web View'),
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
                ],
              ),
            )
          : EasyWebView(
              src: src,
              isHtml: _isHtml,
              isMarkdown: _isMarkdown,
              convertToWidgets: _useWidgets,
              // width: 100,
              // height: 100,
            ),
    );
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
}

```