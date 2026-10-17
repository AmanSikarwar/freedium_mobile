import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/webview/application/webview_provider.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';
import 'package:freedium_mobile/features/webview/presentation/widgets/article_shimmer.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/features/webview/presentation/webview_screen.dart';

import '../../../test_helpers.dart';
import '../webview_test_helpers.dart';

class _ScreenFreediumUrlService(super.ref) extends FreediumUrlService {
  @override
  Future<String> getActiveUrl() async => 'https://freedium-mirror.cfd';
}

void main() {
  testWidgets('reader toolbar exposes labelled buttons and bookmark actions', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final prefs = await mockPrefs({'auto_switch_mirror': false});
    final platform = FakeWebviewPlatform();
    WebViewPlatform.instance = platform;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => prefs),
          freediumUrlServiceProvider.overrideWith(
            _ScreenFreediumUrlService.new,
          ),
          themeInjectorServiceProvider.overrideWithValue(FakeThemeInjector()),
        ],
        child: const MaterialApp(
          home: WebviewScreen(url: TestFixtures.storyUrl),
        ),
      ),
    );
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final page = platform.controller.requests.single.toString();
    platform.delegate.start(page);
    platform.delegate.finish(page);
    platform.controller.channels['themeApplied']!.onMessageReceived(
      const JavaScriptMessage(message: 'done'),
    );
    await tester.pumpAndSettle();
    for (final label in ['Font size', 'Save bookmark', 'Share article']) {
      final node = tester.getSemantics(findTooltip(label));
      expect(node.getSemanticsData().label, label);
      expect(node.getSemanticsData().flagsCollection.isButton, isTrue);
    }
    await tester.tap(findTooltip('Save bookmark'));
    await tester.pumpAndSettle();
    expect(findTooltip('Remove bookmark'), findsOneWidget);
    await tester.longPress(findTooltip('Remove bookmark'));
    await tester.pumpAndSettle();
    expect(find.text('Move to folder'), findsWidgets);
    semantics.dispose();
  });

  testWidgets('load progress updates do not rebuild the WebView widget', (
    tester,
  ) async {
    final prefs = await mockPrefs({'auto_switch_mirror': false});
    final platform = FakeWebviewPlatform();
    WebViewPlatform.instance = platform;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => prefs),
          freediumUrlServiceProvider.overrideWith(
            _ScreenFreediumUrlService.new,
          ),
          themeInjectorServiceProvider.overrideWithValue(FakeThemeInjector()),
        ],
        child: const MaterialApp(
          home: WebviewScreen(url: TestFixtures.storyUrl),
        ),
      ),
    );
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // A non-Freedium document lets the test observe the normal 70% shimmer
    // cutoff while keeping the platform-view instance mounted.
    platform.delegate.start(TestFixtures.storyUrl);
    await tester.pump();
    final initialWebViewBuildCount = platform.webviewWidgetBuildCount;

    for (final progress in [10, 20, 60]) {
      platform.delegate.progress(progress);
      await tester.pump();

      expect(
        tester
            .widget<M3EProgressIndicator>(find.byType(M3EProgressIndicator))
            .value,
        progress / 100,
      );
      expect(find.byType(ArticleShimmer), findsOneWidget);
      expect(platform.webviewWidgetBuildCount, initialWebViewBuildCount);
    }

    platform.delegate.progress(70);
    await tester.pump();
    expect(find.byType(ArticleShimmer), findsNothing);
    expect(platform.webviewWidgetBuildCount, initialWebViewBuildCount);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('themed pages are revealed only after theme injection', () {
    expect(
      shouldRevealWebView(
        isPageLoaded: true,
        isThemeApplied: false,
        isThemedPage: true,
        hasError: false,
      ),
      isFalse,
    );
    expect(
      shouldRevealWebView(
        isPageLoaded: true,
        isThemeApplied: true,
        isThemedPage: true,
        hasError: false,
      ),
      isTrue,
    );
  });
}
