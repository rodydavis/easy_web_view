import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart' as wv;

import 'base.dart';

class WidgetsWebView extends WebView {
  WidgetsWebView({
    required String src,
    required double? width,
    required double? height,
    required void Function()? onLoaded,
    this.options = const WidgetsWebViewOptions(),
  }) : super(
          src: src,
          width: width,
          height: height,
          onLoaded: onLoaded,
        );

  final WidgetsWebViewOptions options;

  @override
  State<WebView> createState() => WidgetsWebViewState();
}

class WidgetsWebViewOptions {
  const WidgetsWebViewOptions({
    this.buildAsync,
    this.factoryBuilder,
    this.baseUrl,
    this.customStylesBuilder,
    this.customWidgetBuilder,
    this.onErrorBuilder,
    this.onLoadingBuilder,
    this.onTapImage,
    this.onTapUrl,
    this.rebuildTriggers,
    this.textStyle,
    this.isSelectable = false,
    this.enableCaching = true,
    this.onSelectionChanged,
  });

  final bool? buildAsync;
  final bool enableCaching;
  final wv.WidgetFactory Function()? factoryBuilder;
  final bool isSelectable;
  final Uri? baseUrl;
  final wv.CustomStylesBuilder? customStylesBuilder;
  final wv.CustomWidgetBuilder? customWidgetBuilder;
  final wv.OnErrorBuilder? onErrorBuilder;
  final wv.OnLoadingBuilder? onLoadingBuilder;
  final SelectionChangedCallback? onSelectionChanged;
  final void Function(wv.ImageMetadata)? onTapImage;
  final FutureOr<bool> Function(String)? onTapUrl;
  final wv.RebuildTriggers? rebuildTriggers;
  final wv.RenderMode renderMode = wv.RenderMode.column;
  final TextStyle? textStyle;
}

class WidgetsWebViewState extends WebViewState<WidgetsWebView> {
  @override
  Widget builder(BuildContext context, Size size, String contents) {
    return wv.HtmlWidget(
      contents,
      buildAsync: widget.options.buildAsync,
      enableCaching: widget.options.enableCaching,
      factoryBuilder: widget.options.factoryBuilder,
      isSelectable: widget.options.isSelectable,
      key: widget.key,
      baseUrl: widget.options.baseUrl,
      customStylesBuilder: widget.options.customStylesBuilder,
      customWidgetBuilder: widget.options.customWidgetBuilder,
      onErrorBuilder: widget.options.onErrorBuilder,
      onLoadingBuilder: widget.options.onLoadingBuilder,
      onSelectionChanged: widget.options.onSelectionChanged,
      onTapImage: widget.options.onTapImage,
      onTapUrl: widget.options.onTapUrl,
      rebuildTriggers: widget.options.rebuildTriggers,
      renderMode: widget.options.renderMode,
      textStyle: widget.options.textStyle,
    );
  }
}
