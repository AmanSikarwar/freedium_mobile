// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(themeMode)
final themeModeProvider = ThemeModeProvider._();

final class ThemeModeProvider
    extends $FunctionalProvider<ThemeMode, ThemeMode, ThemeMode>
    with $Provider<ThemeMode> {
  ThemeModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeHash();

  @$internal
  @override
  $ProviderElement<ThemeMode> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThemeMode create(Ref ref) {
    return themeMode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeModeHash() => r'14b94448c9d991cca8c5d5cb7921313c744b296c';

@ProviderFor(theme)
final themeProvider = ThemeProvider._();

final class ThemeProvider
    extends
        $FunctionalProvider<
          AppThemeProvider,
          AppThemeProvider,
          AppThemeProvider
        >
    with $Provider<AppThemeProvider> {
  ThemeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeHash();

  @$internal
  @override
  $ProviderElement<AppThemeProvider> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppThemeProvider create(Ref ref) {
    return theme(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppThemeProvider value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppThemeProvider>(value),
    );
  }
}

String _$themeHash() => r'369fb7ca6abb4c8655b4ac500fe1f281f1612632';

@ProviderFor(dynamicTheme)
final dynamicThemeProvider = DynamicThemeProvider._();

final class DynamicThemeProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppThemeProvider>,
          AppThemeProvider,
          FutureOr<AppThemeProvider>
        >
    with $FutureModifier<AppThemeProvider>, $FutureProvider<AppThemeProvider> {
  DynamicThemeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dynamicThemeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dynamicThemeHash();

  @$internal
  @override
  $FutureProviderElement<AppThemeProvider> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AppThemeProvider> create(Ref ref) {
    return dynamicTheme(ref);
  }
}

String _$dynamicThemeHash() => r'4469458df7de718c4f418d2506390679512a1eff';
