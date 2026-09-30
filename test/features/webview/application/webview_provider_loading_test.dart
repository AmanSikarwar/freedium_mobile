import 'package:freedium_mobile/core/services/cache_service.dart';
import 'package:webview_flutter/webview_flutter.dart' show WebViewController;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:freedium_mobile/features/history/application/history_provider.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';
import 'package:freedium_mobile/features/webview/application/webview_provider.dart';

import '../../../test_helpers.dart';
import '../webview_test_helpers.dart';

void main() {
  late ProviderContainer container;
  late FakeWebviewPlatform platform;
  final provider = webviewProvider(TestFixtures.storyUrl);
  setUp(() async {
    container = prefsContainer(await mockPrefs());
    await container.read(settingsProvider.future);
    await container.read(historyProvider.future);
    platform = FakeWebviewPlatform();
    WebViewPlatform.instance = platform;
    container.listen(provider, (_, _) {});
    final notifier = container.read(provider.notifier);
    notifier.setThemeInjector(FakeThemeInjector());
    await notifier.updateColorScheme(
      ColorScheme.fromSeed(seedColor: Colors.blue),
    );
    notifier.createController();
  });
  tearDown(() => container.dispose());

  test('closing readers retains cache until an explicit clear', () async {
    final controller = WebViewController.fromPlatform(platform.controller);
    container.invalidate(provider);
    await container.pump();
    expect(platform.controller.cacheClears, 0);
    expect(platform.controller.channels, isEmpty);
    expect(
      await CacheService().clearWebViewCache(controller: controller),
      isTrue,
    );
    expect(platform.controller.cacheClears, 1);
    expect(platform.controller.storageClears, 1);
  });

  testWidgets('styling failures and missing acknowledgements expose recovery', (
    tester,
  ) async {
    final page = platform.controller.requests.single.toString();
    platform.controller.rejectJavaScript = true;
    platform.delegate.start(page);
    platform.delegate.finish(page);
    await tester.pump();
    expect(container.read(provider).hasError, isTrue);
    expect(container.read(provider).isInitialLoad, isFalse);
    await tester.pump(const Duration(seconds: 1));

    platform.controller.rejectJavaScript = false;
    platform.delegate.start(page);
    platform.delegate.finish(page);
    await tester.pump();
    expect(container.read(provider).hasError, isFalse);
    await tester.pump(const Duration(seconds: 3));
    expect(container.read(provider).hasError, isTrue);
    expect(container.read(provider).isInitialLoad, isFalse);

    platform.delegate.start(page);
    platform.delegate.finish(page);
    await tester.pump();
    platform.controller.channels['themeApplied']!.onMessageReceived(
      const JavaScriptMessage(message: 'done'),
    );
    await tester.pump(const Duration(seconds: 4));
    expect(container.read(provider).hasError, isFalse);
    expect(container.read(provider).isThemeApplied, isTrue);
  });

  testWidgets(
    'HTTP failures exclude error pages and only retry temporary errors',
    (tester) async {
      final page = platform.controller.requests.single.toString();
      platform.delegate.start(page);
      platform.delegate.httpError!(
        HttpResponseError(
          request: WebResourceRequest(uri: Uri.parse('$page/image.png')),
          response: const WebResourceResponse(uri: null, statusCode: 404),
        ),
      );
      expect(container.read(provider).hasError, isFalse);
      expect(platform.controller.requests, hasLength(1));

      platform.delegate.httpError!(
        HttpResponseError(
          request: WebResourceRequest(uri: Uri.parse(page)),
          response: const WebResourceResponse(uri: null, statusCode: 404),
        ),
      );
      platform.controller.channels['ArticleMeta']!.onMessageReceived(
        const JavaScriptMessage(message: '{"title":"Not Found"}'),
      );
      platform.delegate.finish(page);
      await tester.pump(const Duration(seconds: 4));
      expect(container.read(provider).hasError, isTrue);
      expect(container.read(provider).errorMessage, contains('404'));
      expect(platform.controller.requests, hasLength(1));
      expect(container.read(historyProvider).requireValue, isEmpty);

      for (var attempt = 0; attempt < 4; attempt++) {
        final retryPage = platform.controller.requests.last.toString();
        platform.delegate.start(retryPage);
        platform.delegate.httpError!(
          HttpResponseError(
            request: WebResourceRequest(uri: Uri.parse(retryPage)),
            response: WebResourceResponse(
              uri: null,
              statusCode: attempt == 0 ? 429 : 503,
            ),
          ),
        );
        platform.delegate.finish(retryPage);
        await tester.pump();
      }
      expect(platform.controller.requests, hasLength(4));
      expect(container.read(provider).hasError, isTrue);
      expect(container.read(historyProvider).requireValue, isEmpty);
    },
  );
}
