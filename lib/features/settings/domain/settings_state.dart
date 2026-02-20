import 'package:flutter/material.dart';
import 'package:freedium_mobile/core/constants/app_constants.dart';

class FreediumMirror {
  final String name;
  final String url;
  final bool isDefault;
  final bool isCustom;

  const FreediumMirror({
    required this.name,
    required this.url,
    this.isDefault = false,
    this.isCustom = false,
  });

  FreediumMirror copyWith({
    String? name,
    String? url,
    bool? isDefault,
    bool? isCustom,
  }) {
    return FreediumMirror(
      name: name ?? this.name,
      url: url ?? this.url,
      isDefault: isDefault ?? this.isDefault,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'isDefault': isDefault,
      'isCustom': isCustom,
    };
  }

  factory FreediumMirror.fromJson(Map<String, dynamic> json) {
    return FreediumMirror(
      name: json['name'] as String,
      url: json['url'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FreediumMirror &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;
}

class SettingsState {
  final ThemeMode themeMode;
  final double defaultFontSize;
  final List<FreediumMirror> mirrors;
  final String selectedMirrorUrl;
  final bool autoSwitchMirror;
  final int mirrorTimeout;

  const SettingsState({
    this.themeMode = .system,
    this.defaultFontSize = 18.0,
    this.mirrors = const [],
    this.selectedMirrorUrl = AppConstants.freediumMirrorUrl,
    this.autoSwitchMirror = true,
    this.mirrorTimeout = 5,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    double? defaultFontSize,
    List<FreediumMirror>? mirrors,
    String? selectedMirrorUrl,
    bool? autoSwitchMirror,
    int? mirrorTimeout,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      defaultFontSize: defaultFontSize ?? this.defaultFontSize,
      mirrors: mirrors ?? this.mirrors,
      selectedMirrorUrl: selectedMirrorUrl ?? this.selectedMirrorUrl,
      autoSwitchMirror: autoSwitchMirror ?? this.autoSwitchMirror,
      mirrorTimeout: mirrorTimeout ?? this.mirrorTimeout,
    );
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
