import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/core/theme/app_theme.dart';
import 'package:freedium_mobile/features/bookmarks/presentation/bookmarks_screen.dart';
import 'package:freedium_mobile/features/home/presentation/home_screen.dart';
import 'package:freedium_mobile/features/settings/presentation/settings_screen.dart';
import 'package:freedium_mobile/features/shell/presentation/app_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../test_helpers.dart';

Widget _app(SharedPreferences prefs) => ProviderScope(
  overrides: [sharedPreferencesProvider.overrideWith((ref) async => prefs)],
  child: MaterialApp(
    theme: AppTheme(Typography.englishLike2021)
        .theme(ColorScheme.fromSeed(seedColor: const Color(0xff006c4c))),
    home: const AppShell(),
  ),
);

void main() {
  testWidgets('floats a labelled toolbar above the selected destination', (
    tester,
  ) async {
    final prefs = await mockPrefs();
    await tester.pumpWidget(_app(prefs));
    await tester.pumpAndSettle();

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
    final prefs = await mockPrefs();
    await tester.pumpWidget(_app(prefs));
    await tester.pumpAndSettle();

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

  testWidgets('system back returns to the home tab', (tester) async {
    final prefs = await mockPrefs();
    await tester.pumpWidget(_app(prefs));
    await tester.pumpAndSettle();

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
