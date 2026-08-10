import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/shared/widgets/article_card.dart';

void main() {
  group('ArticleCard', () {
    testWidgets('exposes reading progress', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArticleCard(
              title: 'Story',
              subtitle: '42% read',
              url: 'https://medium.com/story',
              progress: 0.42,
              onTap: () {},
            ),
          ),
        ),
      );

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, 0.42);
      expect(indicator.semanticsValue, '42');
    });
  });

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
