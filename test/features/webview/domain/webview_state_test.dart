import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/features/webview/domain/webview_state.dart';

void main() {
  group('WebviewState.copyWith', () {
    test('can clear a stale load error message', () {
      const state = WebviewState(
        hasError: true,
        errorMessage: 'Could not connect to the server.',
      );

      final next = state.copyWith(hasError: false, errorMessage: null);

      expect(next.hasError, isFalse);
      expect(next.errorMessage, isNull);
    });

    test('can clear one-shot user message and article meta', () {
      const state = WebviewState(
        userMessage: 'Saved',
        articleMeta: ArticleMeta(title: 'Story'),
      );

      final next = state.copyWith(userMessage: null, articleMeta: null);

      expect(next.userMessage, isNull);
      expect(next.articleMeta, isNull);
    });
  });
}
