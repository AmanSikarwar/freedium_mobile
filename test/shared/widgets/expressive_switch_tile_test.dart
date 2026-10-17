import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:freedium_mobile/shared/widgets/expressive_switch_tile.dart';

void main() {
  testWidgets('toggles once from the label, switch, drag, and keyboard', (
    tester,
  ) async {
    var value = false;
    var changes = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return ExpressiveSwitchTile(
                title: const Text('Site popups'),
                subtitle: const Text('Show announcements'),
                leading: const Icon(Icons.notifications_outlined),
                value: value,
                onChanged: (next) => setState(() {
                  value = next;
                  changes++;
                }),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Site popups'));
    await tester.pumpAndSettle();
    expect(value, isTrue);
    expect(changes, 1);

    await tester.tap(find.byType(M3ESwitch));
    await tester.pumpAndSettle();
    expect(value, isFalse);
    expect(changes, 2);

    await tester.drag(find.byType(M3ESwitch), const Offset(40, 0));
    await tester.pumpAndSettle();
    expect(value, isTrue);
    expect(changes, 3);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(value, isFalse);
    expect(changes, 4);
  });
}
