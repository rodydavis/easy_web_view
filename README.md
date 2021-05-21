[![Buy Me A Coffee](https://img.shields.io/badge/Donate-Buy%20Me%20A%20Coffee-yellow.svg)](https://www.buymeacoffee.com/rodydavis)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=WSH3GVC49GNNJ)
![github pages](https://github.com/rodydavis/easy_web_view/workflows/github%20pages/badge.svg)
[![GitHub stars](https://img.shields.io/github/stars/rodydavis/easy_web_view?color=blue)](https://github.com/rodydavis/easy_web_view)
[![easy_web_view](https://img.shields.io/pub/v/easy_web_view.svg)](https://pub.dev/packages/easy_web_view)

# easy_web_view

Easy Web Views in Flutter on Web and Mobile!

- Supports HTML Content or a Single Element
- Supports Markdown Source
- Supports convert to Flutter widgets
- Supports remote download of url
- Markdown -> Html
- Html -> Markdown
- Supports change in url
- Selectable Text
- Supports multiple views on the same screen if you provide a unique key

Online Demo: https://rodydavis.github.io/easy_web_view

## Getting Started

Setup iOS Info.plist

```
<key>io.flutter.embedded_views_preview</key>
<true/>
```

For Loading a new url or changing width/height just call setState!

```dart
 EasyWebView(
  src: src,
  isHtml: false, // Use Html syntax
  isMarkdown: false, // Use markdown syntax
  convertToWidgets: false, // Try to convert to flutter widgets
  // width: 100,
  // height: 100,
)
```

## Screenshots

![](https://github.com/rodydavis/easy_web_view/blob/master/doc/screenshots/mobile.png?raw=true)
![](https://github.com/rodydavis/easy_web_view/blob/master/doc/screenshots/web.png?raw=true)
