import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/app.dart';
import 'package:freedium_mobile/core/services/clipboard_service.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/core/services/intent_service.dart';
import 'package:freedium_mobile/core/services/update_service.dart';
import 'package:freedium_mobile/core/theme/theme_provider.dart';
import 'package:freedium_mobile/features/webview/application/webview_provider.dart';
import 'package:freedium_mobile/features/webview/presentation/webview_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import '../../test_helpers.dart';
import '../../features/webview/webview_test_helpers.dart';

class _CountingWebviewPlatform() extends FakeWebviewPlatform {
  int controllerCount = 0;

  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    controllerCount++;
    return super.createPlatformWebViewController(params);
  }
}

Future<void> _finishReader(
  WidgetTester tester,
  _CountingWebviewPlatform platform,
) async {
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
}

void main() {
  for (final reopenFromBelow in [false, true]) {
    testWidgets(
      reopenFromBelow
          ? 'incoming article reuses its reader below another reader'
          : 'sharing a manually opened article keeps its existing controller',
      (tester) async {
        currentRouteNameObserver.reset();
        final prefs = await mockPrefs({
          'has_seen_onboarding': true,
          'auto_switch_mirror': false,
        });
        final intents = StreamController<String>();
        addTearDown(intents.close);
        final platform = _CountingWebviewPlatform();
        WebViewPlatform.instance = platform;
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWith((ref) async => prefs),
              dynamicThemeProvider.overrideWith(
                (ref) => ref.watch(themeProvider),
              ),
              clipboardServiceProvider.overrideWith(
                (ref) => FakeClipboardService(),
              ),
              intentServiceProvider.overrideWith((ref) => FakeIntentService()),
              intentStreamProvider.overrideWith((ref) => intents.stream),
              updateCheckProvider.overrideWith((ref) async => null),
              themeInjectorServiceProvider.overrideWithValue(
                FakeThemeInjector(),
              ),
            ],
            child: const App(),
          ),
        );
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(TextFormField),
          TestFixtures.storyUrl,
        );
        await tester.tap(find.text('Read Article'));
        await _finishReader(tester, platform);
        final initialControllerCount = platform.controllerCount;
        expect(initialControllerCount, 1);

        if (reopenFromBelow) {
          intents.add('https://medium.com/example/another-story');
          await tester.pump();
          await _finishReader(tester, platform);
          expect(platform.controllerCount, 2);
        }
        final beforeReopen = platform.controllerCount;
        intents.add(TestFixtures.storyUrl);
        await tester.pumpAndSettle();

        expect(platform.controllerCount, beforeReopen);
        expect(find.byType(WebviewScreen), findsOneWidget);
        expect(
          tester.widget<WebviewScreen>(find.byType(WebviewScreen)).url,
          TestFixtures.storyUrl,
        );
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
      },
    );
  }
}
