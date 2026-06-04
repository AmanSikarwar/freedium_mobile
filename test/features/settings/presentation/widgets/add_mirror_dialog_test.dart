import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';
import 'package:freedium_mobile/features/settings/presentation/widgets/add_mirror_dialog.dart';

void main() {
  testWidgets('trims pasted mirror input before adding', (tester) async {
    FreediumMirror? addedMirror;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: FilledButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => AddMirrorDialog(
                      onAdd: (mirror) {
                        addedMirror = mirror;
                        return true;
                      },
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), ' Custom ');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      ' HTTPS://custom.example/// ',
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid URL'), findsNothing);
    final mirror = addedMirror;
    expect(mirror, isNotNull);
    expect(mirror!.name, 'Custom');
    expect(mirror.url, 'HTTPS://custom.example');
  });

  testWidgets('stays open and shows an error when a mirror is rejected', (
    tester,
  ) async {
    FreediumMirror? submittedMirror;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: FilledButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => AddMirrorDialog(
                      onAdd: (mirror) {
                        submittedMirror = mirror;
                        return false;
                      },
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Duplicate');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'https://freedium.cfd',
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    expect(submittedMirror?.url, 'https://freedium.cfd');
    expect(
      find.text('Mirror already exists or could not be saved.'),
      findsOneWidget,
    );
    expect(find.byType(AddMirrorDialog), findsOneWidget);
  });

  testWidgets('stays open and shows an error when saving throws', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: FilledButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => AddMirrorDialog(
                      onAdd: (mirror) async {
                        throw Exception('preferences unavailable');
                      },
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Custom');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'https://custom.example',
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    expect(
      find.text('Mirror already exists or could not be saved.'),
      findsOneWidget,
    );
    expect(find.byType(AddMirrorDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
