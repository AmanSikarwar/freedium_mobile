import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/constants/app_constants.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/webview/application/freedium_article_url_builder.dart';
import 'package:freedium_mobile/features/webview/application/webview_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';

import '../webview_test_helpers.dart';

import '../../../test_helpers.dart';

void main() {
  group('WebviewNotifier shareArticle', () {
    testWidgets('shares the displayed article after internal navigation', (
      tester,
    ) async {
      ShareParams? shared;
      final container = await _createContainer((params) async {
        shared = params;
        return const ShareResult('', ShareResultStatus.success);
      });
      addTearDown(container.dispose);
      await container.read(settingsProvider.future);
      final platform = FakeWebviewPlatform();
      WebViewPlatform.instance = platform;
      final provider = webviewProvider(TestFixtures.storyUrl);
      container.listen(provider, (_, _) {});
      final notifier = container.read(provider.notifier);
      notifier.setThemeInjector(FakeThemeInjector());
      notifier.createController();
      final displayed = buildFreediumArticleUri(
        mirrorUrl: AppConstants.freediumMirrorUrl,
        articleUrl: 'https://medium.com/example/second-story',
      );
      platform.delegate.start(displayed.toString());
      expect(notifier.articleUrl(), 'https://medium.com/example/second-story');
      await notifier.shareArticle();
      expect(shared!.uri, displayed);
      container.invalidate(provider);
      await tester.pump(const Duration(milliseconds: 1));
    });

    test('reports a message when sharing is unavailable', () async {
      final capturedParams = <ShareParams>[];
      const articleUrl = TestFixtures.storyUrl;
      final container = await _createContainer((params) async {
        capturedParams.add(params);
        return ShareResult.unavailable;
      });
      addTearDown(container.dispose);

      final provider = webviewProvider(articleUrl);
      container.read(provider);
      await container.read(sharedPreferencesProvider.future);
      await Future<void>.delayed(Duration.zero);

      await container.read(provider.notifier).shareArticle();

      expect(capturedParams, hasLength(1));
      expect(
        capturedParams.single.subject,
        'Read this article without Paywall',
      );
      expect(capturedParams.single.title, 'Share Freedium link');
      expect(
        capturedParams.single.uri,
        buildFreediumArticleUri(
          mirrorUrl: AppConstants.freediumMirrorUrl,
          articleUrl: articleUrl,
        ),
      );
      expect(container.read(provider).userMessage, 'Could not share article');
    });

    test(
      'does not report a message when the share sheet is dismissed',
      () async {
        const articleUrl = TestFixtures.storyUrl;
        final container = await _createContainer(
          (params) async => const ShareResult('', ShareResultStatus.dismissed),
        );
        addTearDown(container.dispose);

        final provider = webviewProvider(articleUrl);
        container.read(provider);
        await container.read(sharedPreferencesProvider.future);
        await Future<void>.delayed(Duration.zero);

        await container.read(provider.notifier).shareArticle();

        expect(container.read(provider).userMessage, isNull);
      },
    );

    test('reports a message when sharing throws', () async {
      const articleUrl = TestFixtures.storyUrl;
      final container = await _createContainer((params) async {
        throw Exception('share unavailable');
      });
      addTearDown(container.dispose);

      final provider = webviewProvider(articleUrl);
      container.read(provider);
      await container.read(sharedPreferencesProvider.future);
      await Future<void>.delayed(Duration.zero);

      await container.read(provider.notifier).shareArticle();

      expect(container.read(provider).userMessage, 'Could not share article');
    });
  });
}

Future<ProviderContainer> _createContainer(ShareLauncher shareLauncher) async {
  await mockPrefs({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async => prefs),
      shareLauncherProvider.overrideWith((ref) => shareLauncher),
    ],
  );
}
