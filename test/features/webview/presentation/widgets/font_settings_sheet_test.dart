import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/webview/presentation/widgets/font_settings_sheet.dart';

void main() {
  group('FontSettingsSheet', () {
    testWidgets('clamps initial font size to slider bounds', (tester) async {
      double? changedValue;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FontSettingsSheet(
                initialFontSize: 100,
                onFontSizeChanged: (value) {
                  changedValue = value;
                },
              ),
            ),
          ),
        ),
      );

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, FontSizeService.maxFontSize);
      expect(slider.min, FontSizeService.minFontSize);
      expect(slider.max, FontSizeService.maxFontSize);
      expect(find.text('Size: 28px'), findsOneWidget);

      await tester.tap(find.text('Reset'));
      await tester.pump();

      expect(changedValue, FontSizeService.defaultFontSize);
      expect(find.text('Size: 18px'), findsOneWidget);
    });
  });
}
