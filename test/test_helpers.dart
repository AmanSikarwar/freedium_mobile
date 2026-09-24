import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/services/clipboard_service.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/core/services/intent_service.dart';
import 'package:listen_sharing_intent/listen_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

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
/// wired to mock prefs, then settles. Returns the mock [prefs] for
/// post-condition assertions.
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
Future<SharedPreferences> pumpApp(
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
  return prefs;
}

/// Shared fixture literals used across the test suite.
abstract final class TestFixtures() {
  /// Bare article URL used by most history/bookmark/clipboard tests.
  static const storyUrl = 'https://medium.com/example/story';

  /// Fixed timestamp used for seeded history/bookmark entries.
  static final seedDate = DateTime.utc(2026, 2, 3);

  /// Second fixed timestamp used for date-grouping tests.
  static final groupDate = DateTime.utc(2026, 8, 10);
}

/// [SharedPreferencesStorePlatform] whose writes always fail, for testing
/// save/remove/clear failure paths. Reads serve [initialValues].
///
/// Unifies the five identical `_FailingSharedPreferencesStore` copies (plus
/// three no-arg variants) previously scattered across test files.
class FailingPrefsStore([Map<String, Object>? initialValues])
    extends SharedPreferencesStorePlatform {
  this : _values = Map.of(initialValues ?? {});

  final Map<String, Object> _values;

  @override
  Future<bool> clear() async => false;

  @override
  Future<Map<String, Object>> getAll() async => Map.of(_values);

  @override
  Future<bool> remove(String key) async => false;

  @override
  Future<bool> setValue(String valueType, String key, Object value) async =>
      false;
}

/// Configurable [ClipboardService] fake tracking paste calls.
///
/// Unifies the two same-named `_FakeClipboardService` fakes: the app-level
/// one (always pastes `null`) is `FakeClipboardService()`, and the home
/// one (scripted text + counter) is `FakeClipboardService(text)`.
class FakeClipboardService([this.text]) extends ClipboardService {
  String? text;
  int pasteCount = 0;

  @override
  Future<String?> paste() async {
    pasteCount++;
    return text;
  }
}

/// Configurable [IntentService] fake with a scripted stream.
///
/// Unifies the two same-named `_FakeIntentService` fakes: callers that only
/// need `getInitialIntent` use the default empty stream.
class FakeIntentService([
    this._intentStream = const Stream<List<SharedMediaFile>>.empty(),
  ]) extends IntentService {
  final Stream<List<SharedMediaFile>> _intentStream;
  int resetRequests = 0;

  @override
  Stream<List<SharedMediaFile>> get intentStream => _intentStream;

  @override
  Future<List<SharedMediaFile>> getInitialIntent() async => <SharedMediaFile>[];

  @override
  Future<void> reset() async {
    resetRequests++;
  }
}
