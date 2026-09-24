import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/shared/widgets/article_card.dart';
import 'package:freedium_mobile/shared/widgets/library_clear_dialog.dart';
import 'package:freedium_mobile/shared/widgets/library_list_view.dart';
import 'package:freedium_mobile/shared/widgets/library_search_header.dart';

void main() {
  group('LibrarySearchHeader', () {
    Future<void> pumpHeader(
      WidgetTester tester, {
      String query = '',
      ValueChanged<String>? onChanged,
      VoidCallback? onClear,
    }) {
      final controller = TextEditingController(text: query);
      addTearDown(controller.dispose);
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              bottom: LibrarySearchHeader(
                controller: controller,
                hintText: 'Search library…',
                query: query,
                onChanged: onChanged ?? (_) {},
                onClear: onClear ?? () {},
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders hint and reports text changes', (tester) async {
      var changedTo = '';
      await pumpHeader(tester, onChanged: (v) => changedTo = v);

      expect(find.text('Search library…'), findsOneWidget);
      expect(find.byTooltip('Clear search'), findsNothing);

      await tester.enterText(find.byType(SearchBar), 'Example');
      expect(changedTo, 'Example');
    });

    testWidgets('offers clear search for a non-empty query', (tester) async {
      var cleared = false;
      await pumpHeader(tester, query: 'Example', onClear: () => cleared = true);

      await tester.tap(find.byTooltip('Clear search'));
      expect(cleared, isTrue);
    });
  });

  group('showLibraryClearDialog', () {
    testWidgets('clears and pops on confirm', (tester) async {
      var cleared = false;
      var onCleared = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: FilledButton(
                  onPressed: () => showLibraryClearDialog(
                    context: context,
                    title: 'Clear Library',
                    content: 'Remove everything?',
                    failMessage: 'Failed',
                    onClear: () async {
                      cleared = true;
                      return true;
                    },
                    onCleared: () => onCleared = true,
                  ),
                  child: const Text('Open'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Clear'));
      await tester.pumpAndSettle();

      expect(cleared, isTrue);
      expect(onCleared, isTrue);
      expect(find.text('Clear Library'), findsNothing);
    });

    testWidgets('stays open and shows an error when clearing fails', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: FilledButton(
                  onPressed: () => showLibraryClearDialog(
                    context: context,
                    title: 'Clear Library',
                    content: 'Remove everything?',
                    failMessage: 'Failed',
                    onClear: () async => false,
                    onCleared: () {},
                  ),
                  child: const Text('Open'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Clear'));
      await tester.pumpAndSettle();

      expect(find.text('Clear Library'), findsOneWidget);
      expect(find.text('Failed'), findsOneWidget);
    });
  });

  group('LibraryListView', () {
    const grouped = [
      ('Today', 'b-story'),
      ('Today', 'a-story'),
      ('Yesterday', 'old-story'),
    ];

    Widget buildList({
      Future<bool> Function(String item)? onRemove,
      String removeFailMessage = 'Failed to remove entry',
    }) {
      return MaterialApp(
        home: Scaffold(
          body: LibraryListView<String>(
            grouped: grouped,
            keyFor: (item) => item,
            titleFor: (item) => item,
            subtitleFor: (item) => 'sub of $item',
            urlFor: (item) => 'https://medium.com/$item',
            progressFor: (_) => null,
            trailingFor: (_) => null,
            onRemove: onRemove ?? (_) async => true,
            removeFailMessage: removeFailMessage,
            onTap: (_) {},
          ),
        ),
      );
    }

    testWidgets('groups items under date headers', (tester) async {
      await tester.pumpWidget(buildList());
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);
      expect(find.text('b-story'), findsOneWidget);
      expect(find.text('a-story'), findsOneWidget);
      expect(find.text('old-story'), findsOneWidget);
    });

    testWidgets('removes an entry after swipe dismissal', (tester) async {
      final removed = <String>[];
      await tester.pumpWidget(
        buildList(
          onRemove: (item) async {
            removed.add(item);
            return true;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.text('a-story'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(removed, ['a-story']);
    });

    testWidgets('keeps the entry and shows an error when removal fails', (
      tester,
    ) async {
      await tester.pumpWidget(buildList(onRemove: (_) async => false));
      await tester.pumpAndSettle();

      await tester.drag(find.text('a-story'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.text('a-story'), findsOneWidget);
      expect(find.text('Failed to remove entry'), findsOneWidget);
    });

    testWidgets('uses the shared empty-state building blocks', (tester) async {
      await tester.pumpWidget(buildList());
      await tester.pumpAndSettle();

      // Headers and dismiss backgrounds come from the shared widgets.
      expect(find.byType(DateGroupHeader), findsNWidgets(2));
      await tester.drag(find.text('b-story'), const Offset(-300, 0));
      await tester.pump();
      expect(find.byType(ArticleDismissBackground), findsOneWidget);
    });
  });
}
