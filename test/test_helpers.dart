import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// NOTE: these helpers intentionally do not accept extra provider overrides.
// Riverpod 3 keeps the `Override` type internal, so it cannot be named in a
// parameter type from user code. Call sites needing extra overrides keep
// their inline `overrides: [...]` list and use [mockPrefs] for setup.

/// Creates mock [SharedPreferences] preloaded with [initialValues].
///
/// Replaces the repeated two-line idiom:
/// ```dart
/// SharedPreferences.setMockInitialValues(initialValues);
/// final prefs = await SharedPreferences.getInstance();
/// ```
Future<SharedPreferences> mockPrefs([
  Map<String, Object> initialValues = const {},
]) async {
  SharedPreferences.setMockInitialValues(initialValues);
  return SharedPreferences.getInstance();
}

/// Creates a [ProviderContainer] serving mock [prefs].
ProviderContainer prefsContainer(SharedPreferences prefs) {
  return ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWith((ref) async => prefs)],
  );
}

/// Pumps [child] as the home of a [MaterialApp] inside a [ProviderScope]
/// wired to mock prefs, then settles.
///
/// Covers the standard screen-test scaffolding:
/// ```dart
/// await tester.pumpWidget(
///   ProviderScope(
///     overrides: [sharedPreferencesProvider.overrideWith(...)],
///     child: const MaterialApp(home: SomeScreen()),
///   ),
/// );
/// await tester.pumpAndSettle();
/// ```
Future<void> pumpApp(
  WidgetTester tester, {
  required Widget child,
  Map<String, Object> initialPrefs = const {},
}) async {
  final prefs = await mockPrefs(initialPrefs);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWith((ref) async => prefs)],
      child: MaterialApp(home: child),
    ),
  );
  await tester.pumpAndSettle();
}
