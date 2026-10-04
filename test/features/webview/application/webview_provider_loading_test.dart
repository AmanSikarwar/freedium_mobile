import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/services/cache_service.dart';
import 'package:freedium_mobile/features/history/application/history_provider.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';
import 'package:freedium_mobile/features/webview/application/freedium_article_url_builder.dart';
import 'package:freedium_mobile/features/webview/application/webview_provider.dart';
import 'package:material_ui/material_ui.dart';
import 'package:webview_flutter/webview_flutter.dart' show WebViewController;
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import '../../../test_helpers.dart';
import '../webview_test_helpers.dart';

void main() {
  late ProviderContainer container;
  late FakeWebviewPlatform platform;
  var containerDisposed = false;
  final provider = webviewProvider(TestFixtures.storyUrl);
  setUp(() async {
    containerDisposed = false;
    container = prefsContainer(
      await mockPrefs({
        'freedium_mirrors': [
          jsonEncode(SettingsState.defaultMirrors.single.toJson()),
          for (var i = 0; i < 3; i++)
            jsonEncode(
              FreediumMirror(
                name: 'Fallback $i',
                url: 'https://fallback-$i.example',
              ).toJson(),
            ),
        ],
      }),
    );
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
  tearDown(() {
    if (!containerDisposed) container.dispose();
  });

  testWidgets('an unfinished page triggers bounded mirror failover', (
    tester,
  ) async {
    platform.delegate.start(platform.controller.requests.single.toString());
    await tester.pump(const Duration(seconds: 16));
    expect(platform.controller.requests, hasLength(2));
    expect(container.read(provider).isPageLoaded, isFalse);
    container.invalidate(provider);
    await tester.pump(const Duration(milliseconds: 1));
  });

  test('HTTP error before page start still switches mirrors', () async {
    final failed = platform.controller.requests.single.toString();
    platform.delegate.httpError!(
      HttpResponseError(
        request: WebResourceRequest(uri: Uri.parse(failed)),
        response: const WebResourceResponse(uri: null, statusCode: 503),
      ),
    );
    expect(platform.controller.requests, hasLength(2));
    final pending = platform.controller.requests.last.toString();
    platform.delegate.start(failed);
    platform.delegate.finish(failed);
    expect(container.read(provider).currentUrl, pending);
    expect(container.read(provider).isPageLoaded, isFalse);
  });

  test(
    'main-frame navigation waits for an immediate progress snapshot',
    () async {
      await container
          .read(historyProvider.notifier)
          .addHistory(TestFixtures.storyUrl, 'Story');
      final currentUrl = platform.controller.requests.single.toString();
      platform.delegate.start(currentUrl);
      platform.controller.channels['ArticleMeta']!.onMessageReceived(
        const JavaScriptMessage(message: '{"title":"Story"}'),
      );
      platform.delegate.finish(currentUrl);
      await Future<void>.delayed(Duration.zero);

      final snapshot = Completer<Object>();
      platform.controller.readingProgressCompleter = snapshot;
      final nextUrl = buildFreediumArticleUri(
        mirrorUrl: SettingsState.defaultMirrors.single.url,
        articleUrl: 'https://medium.com/next/story',
      ).toString();
      final navigation = platform.delegate.navigationRequest!(
        NavigationRequest(url: nextUrl, isMainFrame: true),
      );
      await Future<void>.delayed(Duration.zero);

      expect(platform.controller.returningJavaScript, isNotEmpty);
      expect(container.read(provider).currentUrl, currentUrl);

      snapshot.complete(0.73);
      expect(await navigation, NavigationDecision.navigate);
      expect(container.read(provider).currentUrl, nextUrl);
      expect(
        container
            .read(historyProvider)
            .requireValue
            .singleWhere((item) => item.url == TestFixtures.storyUrl)
            .progress,
        0.73,
      );
    },
  );

  testWidgets('main-frame navigation continues if progress snapshot stalls', (
    tester,
  ) async {
    final currentUrl = platform.controller.requests.single.toString();
    platform.delegate.start(currentUrl);
    platform.controller.channels['ArticleMeta']!.onMessageReceived(
      const JavaScriptMessage(message: '{"title":"Story"}'),
    );
    platform.delegate.finish(currentUrl);
    await tester.pump();

    platform.controller.readingProgressCompleter = Completer<Object>();
    final nextUrl = buildFreediumArticleUri(
      mirrorUrl: SettingsState.defaultMirrors.single.url,
      articleUrl: 'https://medium.com/next/story',
    ).toString();
    final navigation = platform.delegate.navigationRequest!(
      NavigationRequest(url: nextUrl, isMainFrame: true),
    );

    await tester.pump(const Duration(seconds: 1));
    expect(await navigation, NavigationDecision.navigate);
    expect(container.read(provider).currentUrl, nextUrl);
    container.dispose();
    containerDisposed = true;
  });

  test(
    'stale navigation cannot overwrite a page that already replaced it',
    () async {
      await container
          .read(historyProvider.notifier)
          .addHistory(TestFixtures.storyUrl, 'Story');
      final currentUrl = platform.controller.requests.single.toString();
      platform.delegate.start(currentUrl);
      platform.controller.channels['ArticleMeta']!.onMessageReceived(
        const JavaScriptMessage(message: '{"title":"Story"}'),
      );
      platform.delegate.finish(currentUrl);
      await Future<void>.delayed(Duration.zero);

      final snapshot = Completer<Object>();
      platform.controller.readingProgressCompleter = snapshot;
      final staleNavigationUrl = buildFreediumArticleUri(
        mirrorUrl: SettingsState.defaultMirrors.single.url,
        articleUrl: 'https://medium.com/stale/story',
      ).toString();
      final navigation = platform.delegate.navigationRequest!(
        NavigationRequest(url: staleNavigationUrl, isMainFrame: true),
      );
      await Future<void>.delayed(Duration.zero);

      final nextUrl = buildFreediumArticleUri(
        mirrorUrl: SettingsState.defaultMirrors.single.url,
        articleUrl: 'https://medium.com/next/story',
      ).toString();
      platform.delegate.start(nextUrl);
      snapshot.complete(0.73);
      expect(await navigation, NavigationDecision.prevent);

      expect(
        container
            .read(historyProvider)
            .requireValue
            .singleWhere((item) => item.url == TestFixtures.storyUrl)
            .progress,
        0,
      );
      expect(container.read(provider).currentUrl, nextUrl);
    },
  );

  test('closing readers retains cache until an explicit clear', () async {
    final controller = WebViewController.fromPlatform(platform.controller);
    container.invalidate(provider);
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
    final notifier = container.read(provider.notifier);
    expect(notifier.canContinueWithoutStyling(), isTrue);
    notifier.continueWithoutStyling();
    expect(container.read(provider).hasError, isFalse);
    expect(container.read(provider).useOriginalStyling, isTrue);
    expect(container.read(provider).isThemeApplied, isFalse);
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
