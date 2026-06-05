import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/shared/widgets/article_card.dart';

void main() {
  group('DateGroupHeader', () {
    testWidgets('uses neutral letter spacing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DateGroupHeader(label: 'Today')),
        ),
      );

      final text = tester.widget<Text>(find.text('Today'));
      expect(text.style?.letterSpacing, 0);
    });
  });
}
