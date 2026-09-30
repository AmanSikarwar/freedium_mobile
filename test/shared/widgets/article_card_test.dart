import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/shared/widgets/article_card.dart';

void main() {
  group('ArticleCard', () {
    testWidgets(
      'trailing actions remain accessible and separate from opening',
      (tester) async {
        final semantics = tester.ensureSemantics();
        var opened = false;
        var moved = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ArticleCard(
                title: 'Story',
                subtitle: 'Saved',
                url: 'https://medium.com/story',
                onTap: () => opened = true,
                trailingIcon: IconButton(
                  tooltip: 'Move to folder',
                  icon: const Icon(Icons.folder),
                  onPressed: () => moved = true,
                ),
              ),
            ),
          ),
        );
        expect(
          tester.getSemantics(find.byTooltip('Move to folder')),
          matchesSemantics(
            tooltip: 'Move to folder',
            isButton: true,
            hasTapAction: true,
            hasFocusAction: true,
            isFocusable: true,
            hasEnabledState: true,
            isEnabled: true,
          ),
        );
        await tester.tap(find.byTooltip('Move to folder'));
        expect(moved, isTrue);
        expect(opened, isFalse);
        semantics.dispose();
      },
    );

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
      expect(find.text('medium.com'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });
  });

  group('LibraryEmptyState', () {
    testWidgets('offers a recovery action', (tester) async {
      var cleared = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LibraryEmptyState(
              icon: Icons.search_off,
              title: 'No results',
              message: 'Try another title or URL.',
              actionLabel: 'Clear search',
              onAction: () => cleared = true,
            ),
          ),
        ),
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Clear search'));

      expect(cleared, isTrue);
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
