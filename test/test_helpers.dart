import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/services/clipboard_service.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/core/services/intent_service.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:receive_intent/receive_intent.dart' as platform;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

Finder findTooltip(String message) => find.byWidgetPredicate(
  (widget) =>
      widget is M3ETooltip && widget.message == message ||
      widget is RawTooltip && widget.semanticsTooltip == message,
  description: 'tooltip "$message"',
);

// NOTE: these helpers intentionally do not accept extra provider overrides.
// Riverpod 3 keeps the `Override` type internal, so it cannot be named in a
// parameter type from user code. Call sites needing extra overrides keep
// their inline `overrides: [...]` list and use [mockPrefs] for setup.

/// Creates cached preferences backed by an in-memory platform store.
Future<SharedPreferencesWithCache> mockPrefs([
  Map<String, Object> initialValues = const {},
]) async {
  SharedPreferences.setMockInitialValues({});
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.withData(initialValues);
  return testPrefs();
}

Future<SharedPreferencesWithCache> testPrefs() =>
    SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );

/// Creates a [ProviderContainer] serving mock [prefs].
ProviderContainer prefsContainer(SharedPreferencesWithCache prefs) {
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
Future<SharedPreferencesWithCache> pumpApp(
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

/// Reads fixtures but fails every write, preserving failure-path coverage.
base class FailingPrefsStore([Map<String, Object>? initialValues])
    extends InMemorySharedPreferencesAsync {
  this
    : super.withData({
        for (final entry in (initialValues ?? <String, Object>{}).entries)
          entry.key.replaceFirst(RegExp(r'^flutter\.'), ''): entry.value,
      });

  @override
  Future<bool> clear(
    ClearPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async => throw Exception('Failed to remove preferences');
  @override
  Future<bool> setString(
    String key,
    String value,
    SharedPreferencesOptions options,
  ) async => throw Exception('Failed to save $key');
  @override
  Future<bool> setStringList(
    String key,
    List<String> value,
    SharedPreferencesOptions options,
  ) async => throw Exception('Failed to save $key');
  @override
  Future<bool> setInt(
    String key,
    int value,
    SharedPreferencesOptions options,
  ) async => throw Exception('Failed to save $key');
  @override
  Future<bool> setDouble(
    String key,
    double value,
    SharedPreferencesOptions options,
  ) async => throw Exception('Failed to save $key');
  @override
  Future<bool> setBool(
    String key,
    bool value,
    SharedPreferencesOptions options,
  ) async => throw Exception('Failed to save $key');
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
  Future<String?> detectUrl() => paste();

  @override
  Future<String?> paste() async {
    pasteCount++;
    return text;
  }
}

/// Configurable [IntentService] fake with a scripted stream and initial
/// intent.
///
/// Callers that only need `getInitialIntent` pass it positionally and
/// read nothing back from the default empty stream.
class FakeIntentService([
  this._intentStream = const Stream<platform.Intent?>.empty(),
  this._initialIntent,
]) extends IntentService {
  final Stream<platform.Intent?> _intentStream;
  final platform.Intent? _initialIntent;

  @override
  Stream<platform.Intent?> get intentStream => _intentStream;

  @override
  Future<platform.Intent?> getInitialIntent() async => _initialIntent;
}
