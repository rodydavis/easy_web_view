import '../extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart' as wv;

import 'base.dart';

class WidgetsWebView extends WebView {
  WidgetsWebView({
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
  State<WebView> createState() => WidgetsWebViewState();
}

class WidgetsWebViewState extends WebViewState<WidgetsWebView> {
  @override
  Widget builder(BuildContext context, Size size, String contents) {
    final options = widget.options.widgets;
    return wv.HtmlWidget(
      contents.toHtml(),
      buildAsync: options.buildAsync,
      enableCaching: options.enableCaching,
      factoryBuilder: options.factoryBuilder,
      isSelectable: options.isSelectable,
      key: widget.key,
      baseUrl: options.baseUrl,
      customStylesBuilder: options.customStylesBuilder,
      customWidgetBuilder: options.customWidgetBuilder,
      onErrorBuilder: options.onErrorBuilder,
      onLoadingBuilder: options.onLoadingBuilder,
      onSelectionChanged: options.onSelectionChanged,
      onTapImage: options.onTapImage,
      onTapUrl: options.onTapUrl,
      rebuildTriggers: options.rebuildTriggers,
      renderMode: options.renderMode,
      textStyle: options.textStyle,
    );
  }
}
