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
    r'a75bcbfc0bd13f2ae6bf691919286acafd6fc10b';

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

String _$pendingIntentUrlHash() => r'2ee7e5c0e19100b049869d33a36558b9b87dffe2';

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
