import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/layout/floating_toolbar.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

void main() {
  testWidgets('clears the pill, its bottom margin, and the safe area', (
    tester,
  ) async {
    late double clearance;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(padding: EdgeInsets.only(bottom: 24)),
        child: Builder(
          builder: (context) {
            clearance = floatingToolbarClearance(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(
      clearance,
      M3EToolbarTokens.containerSize + M3EToolbarTokens.screenOffset + 8 + 24,
    );
  });
}
