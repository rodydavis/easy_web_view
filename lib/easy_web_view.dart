import 'dart:async';

export 'src/unsupported.dart'
    if (dart.library.html) 'src/web.dart'
    if (dart.library.io) 'src/mobile.dart';

enum WebNavigationDecision { navigate, prevent }

class WebNavigationRequest {
  WebNavigationRequest(this.url);

  final String url;
}

typedef FutureOr<WebNavigationDecision> WebNavigationDelegate(
    WebNavigationRequest webNavigationRequest);

class CrossWindowEvent {
  final String name;
  final Function(dynamic) eventAction;

  CrossWindowEvent({
    required this.name,
    required this.eventAction,
  });
}

typedef OnLoaded = void Function(EasyWebViewControllerWrapperBase controller);

abstract class EasyWebViewControllerWrapperBase {
  /// WebViewController on mobile, IFrameElement on web
  Object get nativeWrapper;

  Future<void> evaluateJSMobile(String js);
  Future<String> evaluateJSWithResMobile(String js);

  void postMessageWeb(dynamic message, String targetOrigin);
}
