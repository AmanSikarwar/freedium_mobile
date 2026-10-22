import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/core/theme/app_theme.dart';
import 'package:freedium_mobile/features/bookmarks/presentation/bookmarks_screen.dart';
import 'package:freedium_mobile/features/home/presentation/home_screen.dart';
import 'package:freedium_mobile/features/history/presentation/history_screen.dart';
import 'package:freedium_mobile/features/settings/presentation/settings_screen.dart';
import 'package:freedium_mobile/features/shell/presentation/app_shell.dart';

import '../../../test_helpers.dart';

Future<void> _pumpShell(WidgetTester tester) async {
  final prefs = await mockPrefs();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWith((ref) async => prefs)],
      child: MaterialApp(
        theme: AppTheme(Typography.englishLike2021)
            .theme(ColorScheme.fromSeed(seedColor: const Color(0xff006c4c))),
        home: const AppShell(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('floats a labelled toolbar above the selected destination', (
    tester,
  ) async {
    await _pumpShell(tester);

    final toolbar = find.byType(M3EToolbar);
    expect(toolbar, findsOneWidget);
    expect(
      find.descendant(of: toolbar, matching: find.text('Home')),
      findsOneWidget,
    );
    for (final label in ['Home', 'Bookmarks', 'History', 'Settings']) {
      expect(
        find.descendant(of: toolbar, matching: findTooltip(label)),
        findsOneWidget,
      );
    }

    // About stays a Home app bar action instead of a destination.
    expect(
      find.descendant(of: toolbar, matching: findTooltip('About')),
      findsNothing,
    );
    expect(findTooltip('About'), findsOneWidget);
  });

  testWidgets('switches tabs and labels the new destination', (tester) async {
    await _pumpShell(tester);

    final toolbar = find.byType(M3EToolbar);
    await tester.tap(
      find.descendant(
        of: toolbar,
        matching: find.byIcon(Icons.bookmark_border),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BookmarksScreen), findsOneWidget);
    expect(
      find.descendant(of: toolbar, matching: find.text('Bookmarks')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: toolbar, matching: find.text('Home')),
      findsNothing,
    );

    await tester.tap(
      find.descendant(of: toolbar, matching: find.byIcon(Icons.settings)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(
      find.descendant(of: toolbar, matching: find.text('Settings')),
      findsOneWidget,
    );
    expect(find.byType(HomeScreen, skipOffstage: false), findsOneWidget);
  });

  testWidgets('lets tab content scroll above the floating toolbar', (
    tester,
  ) async {
    await _pumpShell(tester);

    final toolbar = find.byType(M3EToolbar);
    await tester.tap(
      find.descendant(of: toolbar, matching: find.byIcon(Icons.settings)),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -4000));
    await tester.pumpAndSettle();

    final lastItem = find.text('Reset to Defaults');
    expect(lastItem, findsOneWidget);
    expect(
      tester.getBottomLeft(lastItem).dy,
      lessThan(tester.getTopLeft(toolbar).dy),
    );
  });

  testWidgets('crossfades between tabs', (tester) async {
    await _pumpShell(tester);

    final toolbar = find.byType(M3EToolbar);
    await tester.tap(
      find.descendant(
        of: toolbar,
        matching: find.byIcon(Icons.bookmark_border),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 110));

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(BookmarksScreen), findsOneWidget);

    final homeOpacity = tester.widget<Opacity>(
      find
          .ancestor(of: find.byType(HomeScreen), matching: find.byType(Opacity))
          .first,
    );
    final bookmarksOpacity = tester.widget<Opacity>(
      find
          .ancestor(
            of: find.byType(BookmarksScreen),
            matching: find.byType(Opacity),
          )
          .first,
    );
    expect(homeOpacity.opacity, inExclusiveRange(0, 1));
    expect(bookmarksOpacity.opacity, inExclusiveRange(0, 1));

    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('keeps the crossfade continuous when tabs change quickly', (
    tester,
  ) async {
    await _pumpShell(tester);

    final toolbar = find.byType(M3EToolbar);
    await tester.tap(
      find.descendant(
        of: toolbar,
        matching: find.byIcon(Icons.bookmark_border),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    double opacityOf(Finder screen) => tester
        .widget<Opacity>(
          find.ancestor(of: screen, matching: find.byType(Opacity)).first,
        )
        .opacity;

    final homeBefore = opacityOf(find.byType(HomeScreen));
    final bookmarksBefore = opacityOf(find.byType(BookmarksScreen));
    expect(homeBefore, inExclusiveRange(0, 1));
    expect(bookmarksBefore, inExclusiveRange(0, 1));

    await tester.tap(
      find.descendant(of: toolbar, matching: find.byIcon(Icons.history)),
    );
    await tester.pump();

    expect(opacityOf(find.byType(HistoryScreen)), lessThan(0.05));
    expect(opacityOf(find.byType(HomeScreen)), closeTo(homeBefore, 0.03));
    expect(
      opacityOf(find.byType(BookmarksScreen)),
      closeTo(bookmarksBefore, 0.03),
    );
  });

  testWidgets('system back returns to the home tab', (tester) async {
    await _pumpShell(tester);

    final toolbar = find.byType(M3EToolbar);
    await tester.tap(
      find.descendant(of: toolbar, matching: find.byIcon(Icons.history)),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: toolbar, matching: find.text('History')),
      findsOneWidget,
    );

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: toolbar, matching: find.text('Home')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: toolbar, matching: find.text('History')),
      findsNothing,
    );
  });
}
