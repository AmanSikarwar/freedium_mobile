import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/webview/application/webview_provider.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';
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
      final node = tester.getSemantics(find.byTooltip(label));
      expect(node.getSemanticsData().tooltip, label);
      expect(node.getSemanticsData().flagsCollection.isButton, isTrue);
    }
    await tester.tap(find.byTooltip('Save bookmark'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Remove bookmark'), findsOneWidget);
    await tester.longPress(find.byTooltip('Remove bookmark'));
    await tester.pumpAndSettle();
    expect(find.text('Move to folder'), findsWidgets);
    semantics.dispose();
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
