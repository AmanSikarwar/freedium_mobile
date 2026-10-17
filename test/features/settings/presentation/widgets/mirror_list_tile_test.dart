import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';
import 'package:freedium_mobile/features/settings/presentation/widgets/mirror_list_tile.dart';

void main() {
  for (final (width, scale) in [(420.0, 1.3), (320.0, 2.0)]) {
    testWidgets(
      'keeps the mirror name and badge inside $width at $scale text scale',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 900);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final mirror = SettingsState.defaultMirrors.first;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: Scaffold(
                body: RadioGroup<String>(
                  groupValue: mirror.url,
                  onChanged: (_) {},
                  child: MirrorListTile(mirror: mirror, isSelected: true),
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        final card = tester.getRect(find.byType(M3ECard));
        final title = tester.getRect(find.text(mirror.name));
        final badge = tester.getRect(find.text('Default'));
        expect(title.right, lessThanOrEqualTo(card.right));
        expect(badge.right, lessThanOrEqualTo(card.right));
      },
    );
  }
}
