import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_windows/webview_windows.dart' as wv;

import '../extensions.dart';
import 'base.dart';

class WindowsWebView extends WebView {
  WindowsWebView({
    required String src,
    required double? width,
    required double? height,
    required void Function()? onLoaded,
    this.options = const WindowsWebViewOptions(),
  }) : super(
          src: src,
          width: width,
          height: height,
          onLoaded: onLoaded,
        );

  final WindowsWebViewOptions options;

  @override
  State<WebView> createState() => WindowsWebViewState();
}

class WindowsWebViewOptions {
  const WindowsWebViewOptions({
    this.popupWindowPolicy = wv.WebviewPopupWindowPolicy.deny,
    this.backgroundColor = Colors.transparent,
    this.onUrlChanged,
    this.onError,
    this.userDataPath,
    this.browserExePath,
    this.additionalArguments,
  });

  final wv.WebviewPopupWindowPolicy popupWindowPolicy;
  final Color backgroundColor;
  final void Function(String)? onUrlChanged;
  final void Function(PlatformException)? onError;
  final String? userDataPath;
  final String? browserExePath;
  final String? additionalArguments;
}

class WindowsWebViewState extends WebViewState<WindowsWebView> {
  final controller = wv.WebviewController();
  bool isSuspended = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> reload() async {
    await controller
        .loadUrl(widget.src.isValidUrl ? widget.src : widget.src.dataUrl);
  }

  Future<void> initPlatformState() async {
    try {
      await wv.WebviewController.initializeEnvironment(
        userDataPath: widget.options.userDataPath,
        browserExePath: widget.options.browserExePath,
        additionalArguments: widget.options.additionalArguments,
      );

      await controller.initialize();
      controller.url.listen((url) {
        if (widget.options.onUrlChanged != null) {
          widget.options.onUrlChanged!(url);
        }
      });

      await controller.setBackgroundColor(widget.options.backgroundColor);
      await controller.setPopupWindowPolicy(widget.options.popupWindowPolicy);
      await reload();

      if (mounted) setState(() {});
    } on PlatformException catch (e) {
      if (widget.options.onError != null) {
        widget.options.onError!(e);
      }
    }
  }

  @override
  void didUpdateWidget(covariant WindowsWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.src != widget.src) {
      reload();
    }
  }

  @override
  Widget builder(BuildContext context, Size size, String contents) {
    return wv.Webview(
      controller,
      permissionRequested: (url, kind, isUserInitiated) => onPermissionRequest(
        context,
        url,
        kind,
        isUserInitiated,
      ),
    );
  }

  Future<wv.WebviewPermissionDecision> onPermissionRequest(
    BuildContext context,
    String url,
    wv.WebviewPermissionKind kind,
    bool isUserInitiated,
  ) async {
    final decision = await showDialog<wv.WebviewPermissionDecision>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission requested'),
        content: Text('Permission needed: \'$kind\''),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, wv.WebviewPermissionDecision.deny);
            },
            child: const Text('Deny'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, wv.WebviewPermissionDecision.allow);
            },
            child: const Text('Allow'),
          ),
        ],
      ),
    );

    return decision ?? wv.WebviewPermissionDecision.none;
  }

  Future<void> suspend() async {
    if (isSuspended) return;
    await controller.suspend();
    isSuspended = true;
  }

  Future<void> resume() async {
    if (!isSuspended) return;
    await controller.resume();
    isSuspended = false;
  }
}
