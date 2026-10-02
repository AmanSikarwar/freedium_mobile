import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/app.dart';
import 'package:freedium_mobile/core/services/update_service.dart';
import 'package:freedium_mobile/features/bookmarks/application/bookmarks_provider.dart';
import 'package:freedium_mobile/features/history/application/history_provider.dart';
import 'package:freedium_mobile/features/home/presentation/home_screen.dart';
import 'package:freedium_mobile/features/settings/application/settings_service.dart';
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';
import 'package:freedium_mobile/features/webview/application/webview_provider.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

const _article = 'https://medium.com/native-reader';
const _nextArticle = 'https://medium.com/native-next';
const _mirror = 'http://127.0.0.1:8787/good';

Future<void> _waitFor(WidgetTester tester, bool Function() condition) async {
  final clock = Stopwatch()..start();
  while (!condition() && clock.elapsed < const Duration(seconds: 30)) {
    await tester.pump(const Duration(milliseconds: 250));
  }
  expect(condition(), isTrue, reason: 'Native reader did not become ready');
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('native failover, article actions, back and progress restore', (
    tester,
  ) async {
    // Local pages exercise the actual Android WebView without a live mirror.
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8787);
    var failedRequests = 0;
    server.listen((request) async {
      final isBroken = request.uri.path.startsWith('/bad');
      if (request.method == 'HEAD') {
        request.response.statusCode = HttpStatus.ok;
      } else if (isBroken) {
        failedRequests++;
        request.response.statusCode = HttpStatus.serviceUnavailable;
        request.response.write('Mirror unavailable');
      } else {
        final next = request.uri.path.contains('native-next');
        request.response.headers.contentType = ContentType.html;
        request.response.write('''<!doctype html><html><head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${next ? 'Next article' : 'Native article'}</title></head><body>
<article><h1>${next ? 'Next article' : 'Native article'}</h1>
<a id="next" href="$_mirror/$_nextArticle">Next article</a>
${List.filled(180, '<p>A paragraph for native scrolling and reading progress.</p>').join()}
</article></body></html>''');
      }
      await request.response.close();
    });
    addTearDown(() => server.close(force: true));

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setBool('has_seen_onboarding', true);
    await SettingsService(prefs).saveAllSettings(
      const SettingsState(
        mirrors: [
          FreediumMirror(
            name: 'Broken',
            url: 'http://127.0.0.1:8787/bad',
            isCustom: true,
          ),
          FreediumMirror(name: 'Local', url: _mirror, isCustom: true),
        ],
        selectedMirrorUrl: 'http://127.0.0.1:8787/bad',
        mirrorTimeout: 2,
      ),
    );
    Uri? shared;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          updateCheckProvider.overrideWith((ref) async => null),
          shareLauncherProvider.overrideWithValue((params) async {
            shared = params.uri;
            return const ShareResult('done', ShareResultStatus.success);
          }),
        ],
        child: const App(),
      ),
    );
    await _waitFor(tester, () => find.byType(HomeScreen).evaluate().isNotEmpty);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HomeScreen)),
    );
    await tester.enterText(find.byType(TextFormField), _article);
    await tester.tap(find.text('Read Article'));
    await _waitFor(
      tester,
      () => container.read(webviewProvider(_article)).isThemeApplied,
    );
    expect(failedRequests, greaterThan(0));
    expect(container.read(webviewProvider(_article)).activeBaseUrl, _mirror);
    final controller = tester
        .widget<WebViewWidget>(find.byType(WebViewWidget))
        .platform
        .params
        .controller;
    await _waitFor(
      tester,
      () =>
          container.read(webviewProvider(_article)).articleMeta?.title ==
          'Native article',
    );
    await controller.runJavaScript(
      'window.scrollTo(0, document.documentElement.scrollHeight * 0.4)',
    );
    await _waitFor(
      tester,
      () =>
          (container.read(historyProvider).value?.firstOrNull?.progress ?? 0) >
          0.2,
    );
    final progress = (await container.read(historyProvider.future))
        .first
        .progress;
    await tester.tap(find.byTooltip('Save bookmark'));
    await _waitFor(
      tester,
      () => container.read(bookmarksProvider.notifier).isBookmarked(_article),
    );
    await controller.runJavaScript("document.getElementById('next').click()");
    await _waitFor(
      tester,
      () =>
          container.read(webviewProvider(_article)).articleMeta?.title ==
          'Next article',
    );
    await tester.tap(find.byTooltip('Save bookmark'));
    await _waitFor(
      tester,
      () =>
          container.read(bookmarksProvider.notifier).isBookmarked(_nextArticle),
    );
    await tester.tap(find.byTooltip('Share article'));
    await _waitFor(tester, () => shared != null);
    expect(shared.toString(), '$_mirror/$_nextArticle');
    await binding.handlePopRoute();
    await _waitFor(
      tester,
      () =>
          container.read(webviewProvider(_article)).articleMeta?.title ==
          'Native article',
    );
    await binding.handlePopRoute();
    await _waitFor(tester, () => find.byType(WebViewWidget).evaluate().isEmpty);
    await _waitFor(
      tester,
      () => find.byType(TextFormField).evaluate().isNotEmpty,
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), _article);
    await tester.tap(find.text('Read Article'));
    await _waitFor(
      tester,
      () => container.read(webviewProvider(_article)).isThemeApplied,
    );
    final reopened = tester
        .widget<WebViewWidget>(find.byType(WebViewWidget))
        .platform
        .params
        .controller;
    double restored = 0;
    await _waitFor(
      tester,
      () => container.read(webviewProvider(_article)).isPageLoaded,
    );
    // Restoration runs after theming; native callbacks need another frame.
    await tester.pump(const Duration(seconds: 1));
    restored = double.parse(
      (await reopened.runJavaScriptReturningResult(
        'window.scrollY / (document.documentElement.scrollHeight - window.innerHeight)',
      )).toString(),
    );
    expect(restored, closeTo(progress, 0.06));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 250));
  });
}
