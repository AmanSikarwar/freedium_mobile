// Native callbacks are simulated; these helpers do not exercise a device.
import 'package:material_ui/material_ui.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:freedium_mobile/features/webview/application/theme_injector_service.dart';

class FakeWebviewPlatform() extends WebViewPlatform {
  late FakeWebviewController controller;
  late FakeWebviewDelegate delegate;
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
  Future<void> removeJavaScriptChannel(String name) async {}
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
  Future<void> runJavaScript(String script) async {
    if (rejectJavaScript) throw StateError('Simulated JavaScript failure');
  }

  @override
  Future<String?> getTitle() async => 'Article';
}

class FakeWebviewDelegate(super.params) extends PlatformNavigationDelegate {
  this : super.implementation();
  late PageEventCallback start;
  late PageEventCallback finish;
  late WebResourceErrorCallback resourceError;
  HttpResponseErrorCallback? httpError;
  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback callback,
  ) async {}
  @override
  Future<void> setOnProgress(ProgressCallback callback) async {}
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
