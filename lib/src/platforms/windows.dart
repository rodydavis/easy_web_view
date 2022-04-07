import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_windows/webview_windows.dart' as wv;

import 'base.dart';

class WindowsWebView extends WebView {
  WindowsWebView({
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
  State<WebView> createState() => WindowsWebViewState();
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
    await controller.loadUrl(url);
  }

  Future<void> initPlatformState() async {
    final options = widget.options.windows;
    try {
      if (options.userDataPath != null ||
          options.browserExePath != null ||
          options.additionalArguments != null) {
        await wv.WebviewController.initializeEnvironment(
          userDataPath: options.userDataPath,
          browserExePath: options.browserExePath,
          additionalArguments: options.additionalArguments,
        );
      }

      await controller.initialize();
      controller.url.listen((url) {
        if (options.onUrlChanged != null) {
          options.onUrlChanged!(url);
        }
      });

      await controller.setBackgroundColor(options.backgroundColor);
      await controller.setPopupWindowPolicy(options.popupWindowPolicy);
      await reload();

      if (mounted) setState(() {});
    } on PlatformException catch (e) {
      if (options.onError != null) {
        options.onError!(e);
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
