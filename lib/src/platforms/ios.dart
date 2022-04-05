import 'native.dart';

class IosWebView extends NativeWebView {
  IosWebView({
    required String src,
    required double? width,
    required double? height,
    required void Function()? onLoaded,
    NativeWebViewOptions options = const NativeWebViewOptions(),
  }) : super(
          src: src,
          width: width,
          height: height,
          onLoaded: onLoaded,
          options: options,
        );
}
