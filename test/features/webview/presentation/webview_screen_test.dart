import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/features/webview/presentation/webview_screen.dart';

void main() {
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
