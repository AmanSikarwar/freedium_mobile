import 'dart:ui' show SemanticsAction, Tristate;

import 'package:freedium_mobile/shared/widgets/expressive_icon_button.dart';

import '../../test_helpers.dart';

import 'package:material_3_expressive/material_3_expressive.dart';
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
                trailingIcon: ExpressiveIconButton(
                  tooltip: 'Move to folder',
                  icon: const Icon(Icons.folder),
                  onPressed: () => moved = true,
                ),
              ),
            ),
          ),
        );
        final data = tester
            .getSemantics(findTooltip('Move to folder'))
            .getSemanticsData();
        expect(data.label, 'Move to folder');
        expect(data.flagsCollection.isButton, isTrue);
        expect(data.flagsCollection.isEnabled, Tristate.isTrue);
        expect(data.hasAction(SemanticsAction.tap), isTrue);
        await tester.tap(findTooltip('Move to folder'));
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

      final indicator = tester.widget<M3EProgressIndicator>(
        find.byType(M3EProgressIndicator),
      );
      expect(indicator.value, 0.42);
      expect(indicator.semanticsValue, '42');
      expect(find.text('medium.com'), findsOneWidget);
      expect(find.byType(M3ECard), findsOneWidget);
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

      await tester.tap(find.widgetWithText(M3EButton, 'Clear search'));

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
