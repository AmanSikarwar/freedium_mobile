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
  });
}
