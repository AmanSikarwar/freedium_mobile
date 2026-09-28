// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Creates [HttpClient] instances for mirror reachability probes.
/// Overridable in tests to avoid real network access.

@ProviderFor(httpClientFactory)
final httpClientFactoryProvider = HttpClientFactoryProvider._();

/// Creates [HttpClient] instances for mirror reachability probes.
/// Overridable in tests to avoid real network access.

final class HttpClientFactoryProvider
    extends
        $FunctionalProvider<
          HttpClient Function(),
          HttpClient Function(),
          HttpClient Function()
        >
    with $Provider<HttpClient Function()> {
  /// Creates [HttpClient] instances for mirror reachability probes.
  /// Overridable in tests to avoid real network access.
  HttpClientFactoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'httpClientFactoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$httpClientFactoryHash();

  @$internal
  @override
  $ProviderElement<HttpClient Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HttpClient Function() create(Ref ref) {
    return httpClientFactory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HttpClient Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HttpClient Function()>(value),
    );
  }
}

String _$httpClientFactoryHash() => r'90b502ab6e2441570df2acd759aa3ddd89f66d2d';

@ProviderFor(Settings)
final settingsProvider = SettingsProvider._();

final class SettingsProvider
    extends $AsyncNotifierProvider<Settings, SettingsState> {
  SettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsHash();

  @$internal
  @override
  Settings create() => Settings();
}

String _$settingsHash() => r'2e992bdcf69b4bc1890ae648c160a3764cbe29e3';

abstract class _$Settings extends $AsyncNotifier<SettingsState> {
  FutureOr<SettingsState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SettingsState>, SettingsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SettingsState>, SettingsState>,
              AsyncValue<SettingsState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
