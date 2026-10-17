import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/theme/android_color_schemes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('freedium/theme');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const roleNames =
      'primary on_primary primary_container on_primary_container '
      'primary_fixed primary_fixed_dim on_primary_fixed on_primary_fixed_variant '
      'secondary on_secondary secondary_container on_secondary_container '
      'secondary_fixed secondary_fixed_dim on_secondary_fixed on_secondary_fixed_variant '
      'tertiary on_tertiary tertiary_container on_tertiary_container '
      'tertiary_fixed tertiary_fixed_dim on_tertiary_fixed on_tertiary_fixed_variant '
      'error on_error error_container on_error_container '
      'surface on_surface surface_dim surface_bright surface_container_lowest '
      'surface_container_low surface_container surface_container_high '
      'surface_container_highest on_surface_variant outline outline_variant '
      'inverse_surface inverse_on_surface inverse_primary shadow scrim surface_tint';

  Map<String, Map<String, Object?>>? response;
  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    response = {
      for (final mode in ['light', 'dark'])
        mode: {for (final role in roleNames.split(' ')) role: 0xff123456},
    };
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'getColorSchemes');
      return response;
    });
  });
  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  test(
    'keeps resolved native tones, including signed Android color integers',
    () async {
      response!['light']!['surface'] = 0xfff8f7ff;
      response!['dark']!['surface'] = 0xff0f072e.toSigned(32);
      response!['dark']!['primary_container'] = 0xff9496ff.toSigned(32);
      response!['dark']!['inverse_on_surface'] = 0xff123123;
      response!['dark']!['primary_fixed'] = 0xffdedeff;

      final schemes = await loadAndroidColorSchemes();

      expect(schemes, isNotNull);
      expect(schemes!.light.brightness, Brightness.light);
      expect(schemes.light.surface, const Color(0xfff8f7ff));
      expect(schemes.dark.brightness, Brightness.dark);
      expect(schemes.dark.surface, const Color(0xff0f072e));
      expect(schemes.dark.primaryContainer, const Color(0xff9496ff));
      expect(schemes.dark.onInverseSurface, const Color(0xff123123));
      expect(schemes.dark.primaryFixed, const Color(0xffdedeff));
    },
  );

  test('allows palette fallback when native roles are unavailable', () async {
    response = null;
    expect(await loadAndroidColorSchemes(), isNull);
  });

  test(
    'rejects partial native palettes instead of mixing their tones',
    () async {
      response!['dark']!.remove('surface_container_low');
      expect(await loadAndroidColorSchemes(), isNull);
    },
  );

  test('rejects malformed native color values', () async {
    response!['dark']!['primary'] = 'not a color';
    expect(await loadAndroidColorSchemes(), isNull);
  });
}
