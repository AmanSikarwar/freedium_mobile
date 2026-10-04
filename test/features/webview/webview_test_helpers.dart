// Native callbacks are simulated; these helpers do not exercise a device.
import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:freedium_mobile/features/webview/application/theme_injector_service.dart';

class FakeWebviewPlatform() extends WebViewPlatform {
  late FakeWebviewController controller;
  late FakeWebviewDelegate delegate;
  int webviewWidgetBuildCount = 0;
  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) => FakeWebviewWidget(params, onBuild: () => webviewWidgetBuildCount++);

  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) => controller = FakeWebviewController(params);
  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) => delegate = FakeWebviewDelegate(params);
}

class FakeWebviewController(super.params) extends PlatformWebViewController {
  this : super.implementation();
  final requests = <Uri>[];
  bool rejectJavaScript = false;
  int cacheClears = 0;
  int storageClears = 0;
  Object readingProgressResult = 0.0;
  Completer<Object>? readingProgressCompleter;
  final returningJavaScript = <String>[];
  final channels = <String, JavaScriptChannelParams>{};
  @override
  Future<void> setJavaScriptMode(JavaScriptMode mode) async {}
  @override
  Future<void> setBackgroundColor(Color color) async {}
  @override
  Future<void> addJavaScriptChannel(JavaScriptChannelParams params) async {
    channels[params.name] = params;
  }

  @override
  Future<void> removeJavaScriptChannel(String name) async {
    channels.remove(name);
  }

  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate delegate,
  ) async {}
  @override
  Future<void> loadRequest(LoadRequestParams params) async {
    requests.add(params.uri);
  }

  @override
  Future<void> clearCache() async {
    cacheClears++;
  }

  @override
  Future<void> clearLocalStorage() async {
    storageClears++;
  }

  @override
  Future<void> runJavaScript(String script) async {
    if (rejectJavaScript) throw StateError('Simulated JavaScript failure');
  }

  @override
  Future<Object> runJavaScriptReturningResult(String javaScript) {
    returningJavaScript.add(javaScript);
    if (rejectJavaScript) {
      return Future<Object>.error(StateError('Simulated JavaScript failure'));
    }
    return readingProgressCompleter?.future ??
        Future<Object>.value(readingProgressResult);
  }

  @override
  Future<String?> getTitle() async => 'Article';
}

class FakeWebviewDelegate(super.params) extends PlatformNavigationDelegate {
  this : super.implementation();
  late PageEventCallback start;
  late PageEventCallback finish;
  late ProgressCallback progress;
  NavigationRequestCallback? navigationRequest;
  late WebResourceErrorCallback resourceError;
  HttpResponseErrorCallback? httpError;
  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback callback,
  ) async {
    navigationRequest = callback;
  }

  @override
  Future<void> setOnProgress(ProgressCallback callback) async {
    progress = callback;
  }

  @override
  Future<void> setOnPageStarted(PageEventCallback callback) async {
    start = callback;
  }

  @override
  Future<void> setOnPageFinished(PageEventCallback callback) async {
    finish = callback;
  }

  @override
  Future<void> setOnWebResourceError(WebResourceErrorCallback callback) async {
    resourceError = callback;
  }

  @override
  Future<void> setOnHttpError(HttpResponseErrorCallback callback) async {
    httpError = callback;
  }
}

class FakeThemeInjector() extends ThemeInjectorService {
  @override
  Future<String> getThemeInjectionScript(
    ColorScheme colorScheme, {
    double fontSize = 18,
    bool showSitePopups = true,
  }) async => 'theme-script';
}

class FakeWebviewWidget(super.params, {required this.onBuild})
    extends PlatformWebViewWidget {
  this : super.implementation();

  final void Function() onBuild;

  @override
  Widget build(BuildContext context) {
    onBuild();
    return const SizedBox();
  }
}
