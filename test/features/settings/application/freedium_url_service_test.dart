import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';

import '../../../test_helpers.dart';

void main() {
  test('a single mirror opens without a reachability probe', () async {
    final prefs = await mockPrefs();
    var probes = 0;
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWith((ref) async => prefs),
        httpClientFactoryProvider.overrideWith((ref) => () {
          probes++;
          throw StateError('No probe should be needed');
        }),
      ],
    );
    addTearDown(container.dispose);
    final settings = await container.read(settingsProvider.future);

    expect(settings.autoSwitchMirror, isTrue);
    expect(settings.mirrors, hasLength(1));
    expect(
      await container.read(freediumUrlServiceProvider).getActiveUrl(),
      settings.selectedMirrorUrl,
    );
    expect(probes, 0);
  });
}
