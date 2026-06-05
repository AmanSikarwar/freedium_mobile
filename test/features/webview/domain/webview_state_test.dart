import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/features/webview/domain/webview_state.dart';

void main() {
  group('WebviewState.copyWith', () {
    test('can clear a stale load error message', () {
      const state = WebviewState(
        hasError: true,
        errorMessage: 'Could not connect to the server.',
      );

      final next = state.copyWith(hasError: false, clearErrorMessage: true);

      expect(next.hasError, isFalse);
      expect(next.errorMessage, isNull);
    });
  });
}
