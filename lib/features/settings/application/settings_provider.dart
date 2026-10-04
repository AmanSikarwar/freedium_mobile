import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart'
    show sharedPreferencesProvider;
import 'package:freedium_mobile/core/utils/serial_task_queue.dart';
import 'package:freedium_mobile/core/utils/url.dart'
    show hasSameOrigin, isHttpUri, normalizeMirrorUrl, trimTrailingSlash;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:material_ui/material_ui.dart' show ThemeMode;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freedium_mobile/features/settings/application/mirror_probe.dart'
    show probeMirrorUrl;
import 'package:freedium_mobile/features/settings/application/settings_service.dart'
    show SettingsService;
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';

export 'mirror_probe.dart'
    show MirrorProbeResult, probeMirrorUrl, sendMirrorProbeRequest;

part 'settings_provider.freezed.dart';
part 'settings_provider.g.dart';
part 'settings_provider_appearance.dart';
part 'settings_provider_mirror_mutations.dart';
part 'settings_provider_mirror_service.dart';
part 'settings_provider_persistence.dart';

/// Creates [HttpClient] instances for mirror reachability probes.
/// Overridable in tests to avoid real network access.
@Riverpod(keepAlive: true)
HttpClient Function() httpClientFactory(Ref ref) => HttpClient.new;

Duration? _neverRetrySettingsRead(int _, Object _) => null;

@Riverpod(keepAlive: true, retry: _neverRetrySettingsRead)
class Settings() extends _$Settings {
  final _writes = SerialTaskQueue();

  // Keep the notifier API concrete so subclasses can override these methods.
  Future<bool> setThemeMode(ThemeMode themeMode) =>
      _writes.run(() => SettingsAppearance(this)._setThemeMode(themeMode));

  Future<bool> setDefaultFontSize(double fontSize) =>
      _writes.run(() => SettingsAppearance(this)._setDefaultFontSize(fontSize));

  Future<bool> setShowSitePopups(bool show) =>
      _writes.run(() => SettingsAppearance(this)._setShowSitePopups(show));

  Future<bool> addMirror(FreediumMirror mirror) =>
      _writes.run(() => SettingsMirrorMutations(this)._addMirror(mirror));

  Future<bool> removeMirror(FreediumMirror mirror) =>
      _writes.run(() => SettingsMirrorMutations(this)._removeMirror(mirror));

  Future<bool> updateMirror(
    FreediumMirror oldMirror,
    FreediumMirror newMirror,
  ) => _writes.run(
    () => SettingsMirrorMutations(this)._updateMirror(oldMirror, newMirror),
  );

  Future<bool> setSelectedMirror(String url) =>
      _writes.run(() => SettingsMirrorMutations(this)._setSelectedMirror(url));

  Future<bool> setAutoSwitchMirror(bool autoSwitch) => _writes.run(
    () => SettingsMirrorMutations(this)._setAutoSwitchMirror(autoSwitch),
  );

  Future<bool> setMirrorTimeout(int timeout) => _writes.run(
    () => SettingsMirrorMutations(this)._setMirrorTimeout(timeout),
  );

  Future<bool> resetToDefaults() =>
      _writes.run(() => SettingsPersistence(this)._resetToDefaults());

  Future<bool> restoreDefaultsPreservingUnreadableSnapshot() => _writes.run(
    () =>
        SettingsPersistence(this)
            ._restoreDefaultsPreservingUnreadableSnapshot(),
  );

  Future<MirrorTestResult> testMirror(String url) =>
      SettingsMirrorReachability(this)._testMirror(url);

  Future<String?> findWorkingMirror() =>
      SettingsMirrorReachability(this)._findWorkingMirror();

  Ref get _settingsRef => ref;

  set _settingsValue(AsyncValue<SettingsState> value) => state = value;

  /// Current settings, falling back to defaults while loading or on error.
  SettingsState get _current => state.value ?? const SettingsState();

  Future<SettingsService?> _service() async {
    try {
      await future;
      if (!ref.mounted) return null;
      final prefs = await ref.read(sharedPreferencesProvider.future);
      return SettingsService(prefs);
    } catch (e) {
      debugPrint('SettingsService unavailable: $e');
      return null;
    }
  }

  @override
  FutureOr<SettingsState> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    return SettingsService(prefs).loadAllSettings();
  }

  SettingsState _defaultSettings() => SettingsState(
    mirrors: SettingsState.defaultMirrors,
    selectedMirrorUrl: SettingsState.defaultMirrors.first.url,
  );

  Future<bool> _saveAndApply({
    required SettingsService service,
    required SettingsState nextState,
    required String failureMessage,
    bool invalidateCache = false,
  }) async {
    try {
      await service.saveAllSettings(nextState);
      if (!ref.mounted) return false;
      state = AsyncData(nextState);
      if (invalidateCache) {
        ref.read(freediumUrlServiceProvider).invalidateCache();
      }
      return true;
    } catch (e) {
      debugPrint('$failureMessage: $e');
      return false;
    }
  }
}

@freezed
abstract class MirrorTestResult with _$MirrorTestResult {
  const factory MirrorTestResult({
    required bool isReachable,
    required int responseTimeMs,
    int? statusCode,
    String? error,
  }) = _MirrorTestResult;
}
