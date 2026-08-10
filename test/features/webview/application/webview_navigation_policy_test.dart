import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/features/webview/application/webview_provider.dart';

void main() {
  test('reading progress restoration uses the normalized percentage', () {
    final script = buildReadingProgressRestoreScript(0.42);

    expect(script, contains('const progress = 0.42'));
    expect(script, contains('window.scrollTo'));
    expect(script, contains('setTimeout(restore, 1000)'));
  });

  group('resolveWebviewNavigationAction', () {
    bool isFreediumUrl(String url) => Uri.parse(url).host == 'freedium.cfd';

    test('allows freedium mirror navigation to stay in WebView', () {
      expect(
        resolveWebviewNavigationAction(
          requestUrl: ' https://freedium.cfd/https://medium.com/story ',
          isFreediumUrl: isFreediumUrl,
        ),
        WebviewNavigationAction.navigate,
      );
    });

    test('launches external web links outside the WebView', () {
      expect(
        resolveWebviewNavigationAction(
          requestUrl: 'https://example.com/story',
          isFreediumUrl: isFreediumUrl,
        ),
        WebviewNavigationAction.launchExternal,
      );
    });

    test('blocks unsupported and malformed links', () {
      for (final requestUrl in [
        'mailto:author@example.com',
        'javascript:alert(1)',
        '/relative/path',
        'https://',
        '',
      ]) {
        expect(
          resolveWebviewNavigationAction(
            requestUrl: requestUrl,
            isFreediumUrl: isFreediumUrl,
          ),
          WebviewNavigationAction.block,
          reason: requestUrl,
        );
      }
    });
  });
}
