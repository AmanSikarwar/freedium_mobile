import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/app.dart';

void main() {
  group('incoming webview navigation', () {
    test('skips only duplicate incoming webview routes', () {
      const targetUrl = 'https://medium.com/example/story';

      expect(
        shouldSkipIncomingWebviewNavigation(
          currentRouteName: incomingWebviewRouteName(targetUrl),
          targetUrl: targetUrl,
        ),
        isTrue,
      );
      expect(
        shouldSkipIncomingWebviewNavigation(
          currentRouteName: incomingWebviewRouteName(
            'https://medium.com/example/other',
          ),
          targetUrl: targetUrl,
        ),
        isFalse,
      );
      expect(
        shouldSkipIncomingWebviewNavigation(
          currentRouteName: null,
          targetUrl: targetUrl,
        ),
        isFalse,
      );
    });

    testWidgets('tracks the active route for duplicate share detection', (
      tester,
    ) async {
      const targetUrl = 'https://medium.com/example/story';
      final navigatorKey = GlobalKey<NavigatorState>();
      final observer = CurrentRouteNameObserver();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          navigatorObservers: [observer],
          home: const SizedBox.shrink(),
        ),
      );

      navigatorKey.currentState!.push<void>(
        MaterialPageRoute(
          settings: RouteSettings(name: incomingWebviewRouteName(targetUrl)),
          builder: (_) => const SizedBox.shrink(),
        ),
      );
      await tester.pumpAndSettle();

      expect(observer.currentRouteName, incomingWebviewRouteName(targetUrl));
      expect(
        shouldSkipIncomingWebviewNavigation(
          currentRouteName: observer.currentRouteName,
          targetUrl: targetUrl,
        ),
        isTrue,
      );
    });
  });
}
