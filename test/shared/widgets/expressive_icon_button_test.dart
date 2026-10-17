import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:freedium_mobile/shared/widgets/expressive_icon_button.dart';

void main() {
  testWidgets('icon action can be focused and activated with the keyboard', (
    tester,
  ) async {
    var presses = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpressiveIconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add mirror',
            onPressed: () => presses++,
          ),
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(presses, 1);
  });
}
