import 'dart:async';

import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

const readerPlatformChannel = MethodChannel('freedium/webview');

Future<WebViewWidget> createReaderWebView(WebViewController controller) async {
  PlatformWebViewWidgetCreationParams params =
      PlatformWebViewWidgetCreationParams(controller: controller.platform);
  if (WebViewPlatform.instance is AndroidWebViewPlatform) {
    var useHybridComposition = false;
    try {
      final sdk = await readerPlatformChannel
          .invokeMethod<int>('getAndroidSdkVersion')
          .timeout(const Duration(seconds: 1));
      // Native composition avoids the texture path's fast WebView scroll jank.
      // Android <10 has an extra per-frame copy cost, so retain its default.
      useHybridComposition = sdk != null && sdk >= 29;
    } on MissingPluginException {
      // Alternate/test embeddings can retain the plugin's default mode.
    } on PlatformException {
      // A failed capability lookup must not prevent opening an article.
    } on TimeoutException {
      // A non-responsive embedding must not block the reader.
    }
    params =
        AndroidWebViewWidgetCreationParams.fromPlatformWebViewWidgetCreationParams(
          params,
          displayWithHybridComposition: useHybridComposition,
        );
  }
  return WebViewWidget.fromPlatformCreationParams(params: params);
}
