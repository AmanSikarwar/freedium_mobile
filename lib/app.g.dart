// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InitialIntentHandled)
final initialIntentHandledProvider = InitialIntentHandledProvider._();

final class InitialIntentHandledProvider
    extends $NotifierProvider<InitialIntentHandled, bool> {
  InitialIntentHandledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'initialIntentHandledProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$initialIntentHandledHash();

  @$internal
  @override
  InitialIntentHandled create() => InitialIntentHandled();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$initialIntentHandledHash() =>
    r'970bf105f51a4a4501efd5ea49581e27f0da2d6a';

abstract class _$InitialIntentHandled extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(PendingIntentUrl)
final pendingIntentUrlProvider = PendingIntentUrlProvider._();

final class PendingIntentUrlProvider
    extends $NotifierProvider<PendingIntentUrl, String?> {
  PendingIntentUrlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingIntentUrlProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingIntentUrlHash();

  @$internal
  @override
  PendingIntentUrl create() => PendingIntentUrl();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$pendingIntentUrlHash() => r'41958764f64c6ce26cea47502bac876bb8808892';

abstract class _$PendingIntentUrl extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
