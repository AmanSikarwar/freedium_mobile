import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:material_ui/material_ui.dart' show ThemeMode;
import 'package:freedium_mobile/core/constants/app_constants.dart';

part 'settings_state.freezed.dart';
part 'settings_state.g.dart';

@freezed
abstract class FreediumMirror with _$FreediumMirror {
  const factory FreediumMirror({
    required String name,
    required String url,
    @Default(false) bool isDefault,
    @Default(false) bool isCustom,
  }) = _FreediumMirror;

  factory FreediumMirror.fromJson(Map<String, dynamic> json) =>
      _$FreediumMirrorFromJson(json);
}

@freezed
abstract class const SettingsState._() with _$SettingsState {
  const factory SettingsState({
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(SettingsState.defaultDefaultFontSize) double defaultFontSize,
    @Default([]) List<FreediumMirror> mirrors,
    @Default(AppConstants.freediumMirrorUrl) String selectedMirrorUrl,
    @Default(true) bool autoSwitchMirror,
    @Default(SettingsState.defaultMirrorTimeout) int mirrorTimeout,
    @Default(true) bool showSitePopups,
  }) = _SettingsState;

  static const double minDefaultFontSize = 14.0;
  static const double maxDefaultFontSize = 28.0;
  static const double defaultDefaultFontSize = 18.0;
  static const int minMirrorTimeout = 2;
  static const int maxMirrorTimeout = 15;
  static const int defaultMirrorTimeout = 5;

  static double normalizeDefaultFontSize(double fontSize) {
    if (!fontSize.isFinite) return defaultDefaultFontSize;
    return fontSize.clamp(minDefaultFontSize, maxDefaultFontSize).toDouble();
  }

  static int normalizeMirrorTimeout(int timeout) {
    return timeout.clamp(minMirrorTimeout, maxMirrorTimeout).toInt();
  }

  FreediumMirror? get selectedMirror {
    try {
      return mirrors.firstWhere((m) => m.url == selectedMirrorUrl);
    } catch (_) {
      return mirrors.isNotEmpty ? mirrors.first : null;
    }
  }

  static List<FreediumMirror> get defaultMirrors => [
    const FreediumMirror(
      name: 'Freedium Mirror (Primary)',
      url: AppConstants.freediumMirrorUrl,
      isDefault: true,
    ),
    const FreediumMirror(
      name: 'Freedium',
      url: AppConstants.freediumUrl,
      isDefault: true,
    ),
  ];
}
