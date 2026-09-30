import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
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
}
